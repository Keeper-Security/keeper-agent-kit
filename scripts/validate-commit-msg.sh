#!/bin/bash
# Validates Conventional Commits for the commit-msg hook and CI alignment.
# Usage: first argument is the path to the file containing the commit message.

set -euo pipefail

commit_msg_file="${1:-}"

if [ -z "$commit_msg_file" ] || [ ! -f "$commit_msg_file" ]; then
  echo "❌ commit message file path required"
  exit 1
fi

commit_msg=$(cat "$commit_msg_file")
first_line=$(echo "$commit_msg" | head -n1)

# Allow git merge commits
if echo "$first_line" | grep -qE '^Merge '; then
  exit 0
fi

# Conventional Commits: type(scope)!: subject  (scope and ! optional)
# https://www.conventionalcommits.org/
pattern='^(feat|fix|docs|style|refactor|perf|test|build|ci|chore|revert)(\([^)]+\))?(!)?: .+'

if ! echo "$first_line" | grep -qE "$pattern"; then
  echo "❌ Commit message does not follow Conventional Commits."
  echo ""
  echo "Expected: <type>(<scope>): <subject>"
  echo "  or:     <type>(<scope>)!: <subject>   (breaking)"
  echo "  or:     <type>!: <subject>"
  echo ""
  echo "Types: feat, fix, docs, style, refactor, perf, test, build, ci, chore, revert"
  echo ""
  echo "First line was:"
  echo "  $first_line"
  exit 1
fi

subject=$(echo "$first_line" | sed -E 's/^(feat|fix|docs|style|refactor|perf|test|build|ci|chore|revert)(\([^)]+\))?(!)?: //')
if [ -z "$subject" ]; then
  echo "❌ Empty subject after type."
  exit 1
fi
subject_length=${#subject}
if [ "$subject_length" -lt 5 ]; then
  echo "❌ Subject too short (minimum 5 characters after the colon)."
  echo "  Got: '${subject}'"
  exit 1
fi

exit 0
