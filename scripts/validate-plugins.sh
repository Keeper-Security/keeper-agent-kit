#!/usr/bin/env bash
# Validate plugins (Claude/Cursor manifests, marketplaces, skills, references),
# skill triggers, section coverage, markdown code-block heuristics, and root docs.
# Requires bash, jq, and standard POSIX utilities (awk, grep, find, sort).
#
# Markdown example checks run in parallel. Override concurrency with VALIDATE_MAX_JOBS
# (default: min(8, CPU count)).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
export AGENT_KIT_ROOT="$ROOT"
cd "$ROOT"

errors=()
add_err() { errors+=("$1"); }

ok() { printf '  ✓ %s\n' "$1"; }

if ! command -v jq >/dev/null 2>&1; then
  echo "ERROR: jq is required for JSON validation (https://jqlang.org/)" >&2
  exit 2
fi

validate_plugin_json() {
  local label="$1" json="$2"
  local k
  for k in name description version author license keywords repository; do
    if ! jq -e ".${k} != null" "$json" >/dev/null 2>&1; then
      add_err "$label: missing required field '$k'"
    fi
  done
  if ! jq -e '.author | type == "object"' "$json" >/dev/null 2>&1; then
    add_err "$label: 'author' must be an object"
  else
    if ! jq -e '.author.name != null and (.author.name | type == "string")' "$json" >/dev/null 2>&1; then
      add_err "$label: author missing 'name'"
    fi
    if ! jq -e '.author.email != null and (.author.email | type == "string")' "$json" >/dev/null 2>&1; then
      add_err "$label: author missing 'email'"
    fi
  fi
  if ! jq -e '.keywords | type == "array"' "$json" >/dev/null 2>&1; then
    add_err "$label: 'keywords' must be an array"
  fi
}

validate_cursor_logo() {
  local plugin_root="$1" label="$2" json="$3"
  if ! jq -e '.logo != null' "$json" >/dev/null 2>&1; then
    return 0
  fi
  if ! jq -e '.logo | type == "string"' "$json" >/dev/null 2>&1; then
    add_err "$label: 'logo' must be a string"
    return 0
  fi
  local logo
  logo=$(jq -r '.logo' "$json")
  if [[ ! -f "$plugin_root/$logo" ]]; then
    add_err "$label: logo file not found: $plugin_root/$logo"
  fi
}

# SKILL.md: single-line name + description in YAML frontmatter (repo convention)
validate_skill_md() {
  local f="$1" rel="$2"
  local first fm name_line desc_line name_val body

  first=$(head -n1 "$f" | tr -d '\r')
  if [[ "$first" != '---' ]]; then
    add_err "$rel: missing opening ---"
    return
  fi

  fm=$(awk '
    /^---$/ { if (++c == 1) next; if (c == 2) exit }
    c == 1 { print }
  ' "$f")

  if [[ -z "$fm" ]]; then
    add_err "$rel: invalid frontmatter block"
    return
  fi

  name_line=$(echo "$fm" | grep -E '^name:' | head -n1 || true)
  desc_line=$(echo "$fm" | grep -E '^description:' | head -n1 || true)

  if [[ -z "$name_line" ]]; then
    add_err "$rel: frontmatter missing 'name'"
  else
    name_val=$(echo "$name_line" | sed 's/^name:[[:space:]]*//')
    if ((${#name_val} > 64)); then
      add_err "$rel: 'name' must be ≤64 characters"
    fi
  fi

  if [[ -z "$desc_line" ]]; then
    add_err "$rel: frontmatter missing 'description'"
  fi

  body=$(awk '
    /^---$/ { if (++c == 2) { body=1; next } }
    body { print }
  ' "$f")
  if [[ -z "${body//[$' \t\r\n']/}" ]]; then
    add_err "$rel: no body after frontmatter"
  fi
}

validate_marketplace() {
  local mp="$1"
  local n i name src exp got

  if [[ ! -f "$mp" ]]; then
    add_err "Missing marketplace: $mp"
    return
  fi

  if ! jq -e . "$mp" >/dev/null 2>&1; then
    add_err "$mp: invalid JSON"
    return
  fi

  for k in name owner metadata plugins; do
    if ! jq -e ".${k} != null" "$mp" >/dev/null 2>&1; then
      add_err "$mp: missing top-level key '$k'"
    fi
  done

  if ! jq -e '.plugins | type == "array"' "$mp" >/dev/null 2>&1; then
    add_err "$mp: 'plugins' must be an array"
    return
  fi

  n=$(jq '.plugins | length' "$mp")
  u=$(jq '.plugins | map(.name) | unique | length' "$mp")
  if [[ "$n" -ne "$u" ]]; then
    add_err "$mp: duplicate plugin name in plugins[]"
  fi

  for ((i = 0; i < n; i++)); do
    if ! jq -e ".plugins[$i] | type == \"object\"" "$mp" >/dev/null 2>&1; then
      add_err "$mp: plugins[$i] must be an object"
      continue
    fi
    for req in name source description version; do
      if ! jq -e ".plugins[$i].${req} != null" "$mp" >/dev/null 2>&1; then
        add_err "$mp: plugins[$i] missing '$req'"
      fi
    done
    name=$(jq -r ".plugins[$i].name" "$mp")
    src=$(jq -r ".plugins[$i].source" "$mp")
    src="${src#./}"
    if [[ ! -d "$ROOT/$src" ]]; then
      add_err "$mp: plugin '$name' source not a directory: $src"
    else
      exp="$ROOT/plugins/$name"
      got="$(cd "$ROOT/$src" && pwd -P)"
      if [[ "$(cd "$exp" 2>/dev/null && pwd -P)" != "$got" ]]; then
        add_err "$mp: plugin '$name' source path should be ./plugins/$name, got ./$src"
      fi
    fi
  done

  mapfile -t mp_names < <(jq -r '.plugins[].name' "$mp" | sort -u)
  mapfile -t want < <(printf '%s\n' "${plugin_ids[@]}" | sort -u)

  if ! cmp -s <(printf '%s\n' "${mp_names[@]}") <(printf '%s\n' "${want[@]}"); then
    local miss extra
    miss=$(comm -23 <(printf '%s\n' "${want[@]}") <(printf '%s\n' "${mp_names[@]}") | paste -sd, - || true)
    extra=$(comm -13 <(printf '%s\n' "${want[@]}") <(printf '%s\n' "${mp_names[@]}") | paste -sd, - || true)
    [[ -n "$miss" ]] && add_err "$mp: marketplace missing plugins: ${miss//,/, }"
    [[ -n "$extra" ]] && add_err "$mp: marketplace has unknown plugins: ${extra//,/, }"
  fi
}

# --- Skill trigger keywords (description substring match, case-insensitive) ---
_desc_contains() {
  local hay="$1" needle="$2"
  local h n
  h=$(printf '%s' "$hay" | tr '[:upper:]' '[:lower:]')
  n=$(printf '%s' "$needle" | tr '[:upper:]' '[:lower:]')
  [[ "$h" == *"$n"* ]]
}

check_skill_triggers() {
  local f skill_name fm desc total found kw
  mapfile -t _skill_paths < <(find "$ROOT/plugins" -type f -path '*/skills/*/SKILL.md' | sort)
  for f in "${_skill_paths[@]}"; do
    skill_name=$(basename "$(dirname "$f")")
    fm=$(awk '
      /^---$/ { if (++c == 1) next; if (c == 2) exit }
      c == 1 { print }
    ' "$f")
    if [[ -z "$fm" ]]; then
      echo "⚠ $skill_name: No frontmatter"
      continue
    fi
    desc=$(echo "$fm" | grep -E '^description:' | head -n1 | sed 's/^description:[[:space:]]*//')
    if [[ -z "$desc" ]]; then
      echo "⚠ $skill_name: No description in frontmatter"
      continue
    fi
    echo ""
    echo "📋 Skill: $skill_name"
    echo "   Description length: ${#desc} chars"
    total=0
    found=0
    case "$skill_name" in
      keeper-secrets)
        for kw in keeper ksm secret vault credentials 'keeper://' password 'api key' certificate 'ci/cd' docker kubernetes; do
          ((total++)) || true
          if _desc_contains "$desc" "$kw"; then
            ((found++)) || true
          fi
        done
        ;;
      keeper-admin)
        for kw in keeper commander admin enterprise 'user management' pam rotation session; do
          ((total++)) || true
          if _desc_contains "$desc" "$kw"; then
            ((found++)) || true
          fi
        done
        ;;
      keeper-setup)
        for kw in install keeper setup configure ksm commander cli; do
          ((total++)) || true
          if _desc_contains "$desc" "$kw"; then
            ((found++)) || true
          fi
        done
        ;;
      *)
        echo "   ⚠ No expected trigger list for skill id $skill_name"
        continue
        ;;
    esac
    if [[ "$found" -gt 0 ]]; then
      echo "   ✓ Found $found/$total expected triggers"
    else
      echo "   ⚠ No expected triggers found in description"
    fi
  done
  echo ""
  echo "✓ Analyzed ${#_skill_paths[@]} skills"
}

_check_skill_sections() {
  local path="$1" plugin_id="$2"
  shift 2
  local secs=("$@") content missing s
  if [[ ! -f "$ROOT/$path" ]]; then
    add_err "Missing: $path"
    return
  fi
  content=$(cat "$ROOT/$path")
  missing=()
  for s in "${secs[@]}"; do
    if ! printf '%s' "$content" | grep -Fq "$s"; then
      missing+=("$s")
    fi
  done
  if [[ ${#missing[@]} -gt 0 ]]; then
    echo "⚠ $plugin_id: Missing sections: ${missing[*]}"
  else
    echo "✓ $plugin_id: All expected sections present"
  fi
}

check_skill_content_sections() {
  echo "Checking skill content coverage..."
  _check_skill_sections "plugins/keeper-secrets/skills/keeper-secrets/SKILL.md" keeper-secrets \
    "When to Use KSM" "Prerequisites" "Core Commands" "ksm exec" "ksm interpolate" "Guardrails"
  _check_skill_sections "plugins/keeper-admin/skills/keeper-admin/SKILL.md" keeper-admin \
    "When to Use Commander" "Prerequisites" "Vault Operations" "Enterprise Administration" "Guardrails"
  _check_skill_sections "plugins/keeper-setup/skills/keeper-setup/SKILL.md" keeper-setup \
    "Quick Install" "KSM CLI" "Commander" "Troubleshooting"
}

# Scan markdown for fenced code blocks; warn on missing language or suspicious literals.
check_md_file_examples() {
  local filepath="$1"
  local rel="${filepath#"$ROOT"/}"
  local _fence
  _fence=$(printf '\x60\x60\x60')
  local line in_block=0 lang="" code="" issues=()

  while IFS= read -r line || [[ -n "${line:-}" ]]; do
    if [[ "${line:0:3}" == "$_fence" ]]; then
      if [[ "$in_block" -eq 1 ]]; then
        # closing fence
        if [[ -z "$lang" && "$code" == *$'\n'* && -n "${code//[$' \t\r\n']/}" ]]; then
          issues+=("Code block without language specification")
        fi
        if [[ -n "$code" ]]; then
          if printf '%s' "$code" | grep -qiE 'password[[:space:]]*=[[:space:]]*['\''"]' && ! printf '%s' "$code" | grep -qi 'keeper'; then
            issues+=("Possible hardcoded password in example")
          fi
          if printf '%s' "$code" | grep -qiE 'token[[:space:]]*=[[:space:]]*['\''"]' && ! printf '%s' "$code" | grep -qi 'keeper'; then
            issues+=("Possible hardcoded token in example")
          fi
        fi
        in_block=0
        lang=""
        code=""
      else
        # opening fence
        in_block=1
        lang=$(echo "$line" | sed 's/^```//' | awk '{print $1}' | tr -d '\r')
        code=""
      fi
      continue
    fi
    if [[ "$in_block" -eq 1 ]]; then
      code+="$line"$'\n'
    fi
  done <"$filepath"

  if [[ ${#issues[@]} -gt 0 ]]; then
    echo ""
    echo "⚠ $rel:"
    for m in "${issues[@]}"; do
      echo "    - $m"
    done
  else
    echo "✓ $rel"
  fi
}

_validate_max_jobs() {
  local max="${VALIDATE_MAX_JOBS:-8}"
  local ncpu
  ncpu=$(nproc 2>/dev/null || sysctl -n hw.ncpu 2>/dev/null || echo 4)
  if ((max > ncpu)); then max=$ncpu; fi
  if ((max < 1)); then max=1; fi
  printf '%s' "$max"
}

check_md_examples_all() {
  echo "Checking for insecure examples..."
  local max
  max=$(_validate_max_jobs)
  mapfile -t _md_files < <(find "$ROOT/plugins" -type f -name '*.md' | sort)
  if [[ ${#_md_files[@]} -eq 0 ]]; then
    return 0
  fi
  local tmpdir job active
  tmpdir=$(mktemp -d "${TMPDIR:-/tmp}/validate-plugins-md.XXXXXX")
  trap 'rm -rf "$tmpdir"' RETURN
  job=0
  for f in "${_md_files[@]}"; do
    while true; do
      active=$(jobs -p 2>/dev/null | wc -l | tr -d ' ')
      [[ "${active:-0}" -lt "$max" ]] && break
      sleep 0.02
    done
    job=$((job + 1))
    ( check_md_file_examples "$f" >"$tmpdir/$(printf '%05d' "$job").out" ) &
  done
  wait 2>/dev/null || true
  local o
  mapfile -t _outs < <(find "$tmpdir" -maxdepth 1 -name '*.out' -print | sort -V)
  for o in "${_outs[@]}"; do
    cat "$o"
  done
  rm -rf "$tmpdir"
  trap - RETURN
}

check_root_docs() {
  echo "Checking documentation files..."
  local doc sections missing s
  # (file, pipe-separated sections; empty = existence only)
  for doc in README.md SECURITY.md CONTRIBUTING.md LICENSE.md; do
    if [[ ! -f "$ROOT/$doc" ]]; then
      echo "⚠ Missing: $doc"
      continue
    fi
    missing=()
    case "$doc" in
      README.md)
        for s in Installation Prerequisites Documentation Contributing License Security; do
          grep -Fq "$s" "$ROOT/$doc" || missing+=("$s")
        done
        ;;
      SECURITY.md)
        for s in Reporting "Supported versions"; do
          grep -Fq "$s" "$ROOT/$doc" || missing+=("$s")
        done
        ;;
      CONTRIBUTING.md)
        for s in "How to Contribute" "Testing Guidelines" "Submission Checklist"; do
          grep -Fq "$s" "$ROOT/$doc" || missing+=("$s")
        done
        ;;
      LICENSE.md)
        missing=()
        ;;
    esac
    if [[ ${#missing[@]} -gt 0 ]]; then
      echo "⚠ $doc: Missing: ${missing[*]}"
    else
      echo "✓ $doc"
    fi
  done
}

# --- discover plugins (sorted ids) ---
plugin_ids=()
while IFS= read -r line; do
  [[ -n "$line" ]] && plugin_ids+=("$line")
done < <(
  for d in "$ROOT"/plugins/*/; do
    [[ -d "$d" ]] || continue
    base=$(basename "$d")
    [[ "$base" == .* ]] && continue
    if [[ -f "${d}.claude-plugin/plugin.json" || -f "${d}.cursor-plugin/plugin.json" ]]; then
      printf '%s\n' "$base"
    fi
  done | sort
)

if [[ ! -d "$ROOT/plugins" ]]; then
  echo "ERROR: plugins directory not found: $ROOT/plugins"
  exit 1
fi

if [[ ${#plugin_ids[@]} -eq 0 ]]; then
  echo "ERROR: No plugin directories under $ROOT/plugins"
  exit 1
fi

echo "== Plugin manifests (Claude + Cursor) =="
for pid in "${plugin_ids[@]}"; do
  pr="$ROOT/plugins/$pid"
  echo ""
  echo "--- $pid ---"
  cj="$pr/.claude-plugin/plugin.json"
  uj="$pr/.cursor-plugin/plugin.json"

  if [[ ! -f "$cj" ]]; then
    add_err "Missing Claude manifest: $cj"
  else
    if ! jq -e . "$cj" >/dev/null 2>&1; then
      add_err "$cj: invalid JSON"
    else
      validate_plugin_json "$cj" "$cj"
      pname=$(jq -r '.name' "$cj")
      if [[ "$pname" != "$pid" ]]; then
        add_err "$cj: 'name' must match directory ('$pid')"
      else
        ver=$(jq -r '.version' "$cj")
        ok "Claude plugin.json ($ver)"
      fi
    fi
  fi

  if [[ ! -f "$uj" ]]; then
    add_err "Missing Cursor manifest: $uj"
  else
    if ! jq -e . "$uj" >/dev/null 2>&1; then
      add_err "$uj: invalid JSON"
    else
      validate_plugin_json "$uj" "$uj"
      validate_cursor_logo "$pr" "$uj" "$uj"
      pname=$(jq -r '.name' "$uj")
      if [[ "$pname" != "$pid" ]]; then
        add_err "$uj: 'name' must match directory ('$pid')"
      else
        ver=$(jq -r '.version' "$uj")
        ok "Cursor plugin.json ($ver)"
      fi
    fi
  fi
done

echo ""
echo "== Root marketplaces =="
for mp_path in "$ROOT/.claude-plugin/marketplace.json" "$ROOT/.cursor-plugin/marketplace.json"; do
  label="Claude"
  [[ "$mp_path" == *cursor* ]] && label="Cursor"
  echo ""
  echo "--- $label ---"
  n_err=${#errors[@]}
  validate_marketplace "$mp_path"
  if [[ ${#errors[@]} -eq "$n_err" ]]; then
    n=$(jq '.plugins | length' "$mp_path")
    ok "${mp_path#"$ROOT"/}: $n plugins"
  fi
done

echo ""
echo "== SKILL.md files =="
mapfile -t skill_files < <(find "$ROOT/plugins" -type f -path '*/skills/*/SKILL.md' | sort)
if [[ ${#skill_files[@]} -eq 0 ]]; then
  add_err "No SKILL.md files under $ROOT/plugins"
else
  for sf in "${skill_files[@]}"; do
    rel="${sf#"$ROOT"/}"
    echo ""
    echo "Validating $rel"
    n_err=${#errors[@]}
    validate_skill_md "$sf" "$rel"
    if [[ ${#errors[@]} -eq "$n_err" ]]; then
      ok "frontmatter and body"
    fi
  done
fi

echo ""
echo "== Reference docs =="
for rel in \
  "skills/keeper-secrets/references/ksm-commands.md" \
  "skills/keeper-secrets/references/keeper-notation.md" \
  "skills/keeper-secrets/references/ksm-exec-patterns.md"; do
  p="$ROOT/plugins/keeper-secrets/$rel"
  if [[ ! -f "$p" ]]; then
    add_err "Missing reference: $p"
  else
    n=$(wc -l <"$p" | tr -d ' ')
    if [[ "$n" -lt 5 ]]; then
      add_err "Reference file suspiciously short ($n lines): $p"
    else
      ok "keeper-secrets/$rel ($n lines)"
    fi
  fi
done

for rel in \
  "skills/keeper-admin/references/commander-commands.md" \
  "skills/keeper-admin/references/enterprise-mgmt.md" \
  "skills/keeper-admin/references/pam-commands.md" \
  "skills/keeper-admin/references/rotation-commands.md"; do
  p="$ROOT/plugins/keeper-admin/$rel"
  if [[ ! -f "$p" ]]; then
    add_err "Missing reference: $p"
  else
    n=$(wc -l <"$p" | tr -d ' ')
    if [[ "$n" -lt 5 ]]; then
      add_err "Reference file suspiciously short ($n lines): $p"
    else
      ok "keeper-admin/$rel ($n lines)"
    fi
  fi
done

echo ""
echo "== Skill trigger keywords =="
check_skill_triggers

echo ""
echo "== Skill content sections =="
check_skill_content_sections

echo ""
echo "== Skill examples (markdown code blocks) =="
check_md_examples_all

echo ""
echo "== Root documentation =="
check_root_docs

if [[ ${#errors[@]} -gt 0 ]]; then
  echo ""
  echo "❌ Validation failed:"
  for e in "${errors[@]}"; do
    echo "  - $e"
  done
  exit 1
fi

echo ""
echo "✓ All validations passed"
