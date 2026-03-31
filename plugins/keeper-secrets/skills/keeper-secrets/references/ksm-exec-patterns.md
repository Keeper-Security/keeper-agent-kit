# KSM Exec & Interpolation Patterns

Common patterns for using `ksm exec` and `ksm interpolate` across different environments.

Official documentation: [Secrets Manager (KSM)](https://docs.keeper.io/en/keeperpam/secrets-manager/overview) · [Keeper notation](https://docs.keeper.io/en/keeperpam/secrets-manager/about/keeper-notation). See also `keeper-notation.md` in this folder.

## Local Development

### Node.js / npm

```bash
# Install dependencies
npm install

# Run with secrets
DB_URL="keeper://REC_UID/field/url" \
API_KEY="keeper://REC_UID/field/password" \
ksm exec -- npm run dev

# Or in .env.local (not recommended, but pattern shown)
ksm interpolate --in-file .env.keeper --out-file .env.local
npm run dev
```

### Python / pip

```bash
# Run with secrets
DB_PASSWORD="keeper://REC_UID/field/password" \
DATABASE_URL="keeper://REC_UID/field/url" \
ksm exec -- python -m app.main

# Or with poetry
DB_PASSWORD="keeper://REC_UID/field/password" \
ksm exec -- poetry run python -m app.main
```

### Go

```bash
# Run with secrets
DB_HOST="keeper://REC_UID/field/host" \
DB_PORT="keeper://REC_UID/field/port" \
DB_USER="keeper://REC_UID/field/login" \
DB_PASS="keeper://REC_UID/field/password" \
ksm exec -- go run main.go
```

### Ruby / Rails

```bash
# Run Rails with secrets
DATABASE_URL="keeper://REC_UID/field/url" \
API_KEY="keeper://REC_UID/field/password" \
ksm exec -- bundle exec rails server

# Run Rake tasks
DB_PASSWORD="keeper://REC_UID/field/password" \
ksm exec -- bundle exec rake db:migrate
```

## Docker

### Docker Run with Secrets

```bash
# Single secret
docker run \
  -e DB_PASSWORD="keeper://REC_UID/field/password" \
  -e KSM_CONFIG="$(cat ~/.keeper/keeper.ini | base64)" \
  myapp:latest \
  ksm exec -- /start.sh

# Multiple secrets
docker run \
  -e DB_HOST="keeper://REC_UID/field/host" \
  -e DB_PORT="keeper://REC_UID/field/port" \
  -e DB_USER="keeper://REC_UID/field/login" \
  -e DB_PASS="keeper://REC_UID/field/password" \
  -e API_KEY="keeper://API_UID/field/password" \
  -e KSM_CONFIG="<base64>" \
  myapp:latest \
  ksm exec -- /start.sh
```

### Dockerfile with KSM

```dockerfile
FROM python:3.11-slim

# Install KSM
RUN pip install keeper-secrets-manager-cli

# Copy app
COPY . /app
WORKDIR /app

# Dependencies
RUN pip install -r requirements.txt

# Entrypoint with ksm exec
ENTRYPOINT ["ksm", "exec", "--"]
CMD ["python", "-m", "uvicorn", "main:app", "--host", "0.0.0.0"]
```

```bash
# Run it
docker run \
  -e DB_URL="keeper://REC_UID/field/url" \
  -e API_KEY="keeper://REC_UID/field/password" \
  -e KSM_CONFIG="<base64-config>" \
  myapp:latest
```

### Docker Compose

```yaml
version: '3.8'

services:
  app:
    image: myapp:latest
    environment:
      DB_HOST: keeper://DB_UID/field/host
      DB_PORT: keeper://DB_UID/field/port
      DB_USER: keeper://DB_UID/field/login
      DB_PASS: keeper://DB_UID/field/password
      API_KEY: keeper://API_UID/field/password
      KSM_CONFIG: ${KSM_CONFIG}  # Pass via --env-file
    command: ksm exec -- /start.sh

  postgres:
    image: postgres:15
    environment:
      POSTGRES_PASSWORD: keeper://DB_UID/field/password
```

```bash
# Create .env file
echo "KSM_CONFIG=$(cat ~/.keeper/keeper.ini | base64)" > .env

# Run compose
docker-compose up
```

## Kubernetes

### Pod with Secrets

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: app-pod
spec:
  serviceAccountName: app-sa
  containers:
  - name: app
    image: myapp:latest
    env:
    - name: DB_HOST
      value: "keeper://DB_UID/field/host"
    - name: DB_PORT
      value: "keeper://DB_UID/field/port"
    - name: DB_USER
      value: "keeper://DB_UID/field/login"
    - name: DB_PASS
      value: "keeper://DB_UID/field/password"
    - name: API_KEY
      value: "keeper://API_UID/field/password"
    - name: KSM_CONFIG
      valueFrom:
        secretKeyRef:
          name: ksm-config
          key: config
    command: ["ksm", "exec", "--"]
    args: ["/start.sh"]
```

### Setup KSM Secret in Cluster

```bash
# Create KSM config secret
kubectl create secret generic ksm-config \
  --from-literal=config=$(cat ~/.keeper/keeper.ini | base64)

# Or from environment variable
kubectl create secret generic ksm-config \
  --from-literal=config=$KSM_CONFIG
```

### Deployment with Init Container

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app
spec:
  replicas: 3
  selector:
    matchLabels:
      app: myapp
  template:
    metadata:
      labels:
        app: myapp
    spec:
      initContainers:
      # Optional: validate KSM access before starting
      - name: ksm-check
        image: myapp:latest
        env:
        - name: KSM_CONFIG
          valueFrom:
            secretKeyRef:
              name: ksm-config
              key: config
        command: ["ksm", "secret", "list"]
      containers:
      - name: app
        image: myapp:latest
        env:
        - name: DB_PASS
          value: "keeper://DB_UID/field/password"
        - name: API_KEY
          value: "keeper://API_UID/field/password"
        - name: KSM_CONFIG
          valueFrom:
            secretKeyRef:
              name: ksm-config
              key: config
        command: ["ksm", "exec", "--"]
        args: ["/start.sh"]
```

### StatefulSet Example

```yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: postgres
spec:
  serviceName: postgres
  replicas: 1
  selector:
    matchLabels:
      app: postgres
  template:
    metadata:
      labels:
        app: postgres
    spec:
      containers:
      - name: postgres
        image: postgres:15
        env:
        - name: POSTGRES_PASSWORD
          value: "keeper://DB_UID/field/password"
        - name: KSM_CONFIG
          valueFrom:
            secretKeyRef:
              name: ksm-config
              key: config
        command: ["ksm", "exec", "--"]
        args: ["docker-entrypoint.sh", "postgres"]
        volumeMounts:
        - name: data
          mountPath: /var/lib/postgresql/data
  volumeClaimTemplates:
  - metadata:
      name: data
    spec:
      accessModes: ["ReadWriteOnce"]
      resources:
        requests:
          storage: 10Gi
```

## CI/CD Platforms

### GitHub Actions

```yaml
name: Deploy

on:
  push:
    branches: [main]

env:
  KSM_CONFIG: ${{ secrets.KSM_CONFIG }}

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3

    - name: Install dependencies
      run: |
        pip install keeper-secrets-manager-cli
        pip install -r requirements.txt

    - name: Run tests with secrets
      env:
        DB_HOST: keeper://REC_UID/field/host
        DB_USER: keeper://REC_UID/field/login
        DB_PASS: keeper://REC_UID/field/password
      run: ksm exec -- pytest tests/

    - name: Deploy with secrets
      env:
        DEPLOY_KEY: keeper://KEY_UID/file/id_rsa
        API_TOKEN: keeper://API_UID/field/password
      run: ksm exec -- ./deploy.sh
```

### GitLab CI

```yaml
stages:
  - test
  - deploy

variables:
  KSM_CONFIG: $KSM_CONFIG  # Set in CI/CD variables
  DB_HOST: "keeper://REC_UID/field/host"
  DB_USER: "keeper://REC_UID/field/login"
  DB_PASS: "keeper://REC_UID/field/password"

test:
  stage: test
  image: python:3.11
  before_script:
    - pip install keeper-secrets-manager-cli pytest
  script:
    - ksm exec -- pytest tests/

deploy:
  stage: deploy
  image: ubuntu:22.04
  environment: production
  before_script:
    - apt-get update && apt-get install -y python-pip
    - pip install keeper-secrets-manager-cli
  script:
    - ksm exec -- ./deploy.sh
  only:
    - main
```

### Jenkins

```groovy
pipeline {
    agent any

    environment {
        KSM_CONFIG = credentials('ksm-config')
    }

    stages {
        stage('Install') {
            steps {
                sh 'pip install keeper-secrets-manager-cli'
            }
        }

        stage('Test') {
            environment {
                DB_HOST = 'keeper://REC_UID/field/host'
                DB_USER = 'keeper://REC_UID/field/login'
                DB_PASS = 'keeper://REC_UID/field/password'
            }
            steps {
                sh 'ksm exec -- pytest tests/'
            }
        }

        stage('Deploy') {
            environment {
                DEPLOY_KEY = 'keeper://KEY_UID/file/id_rsa'
                API_TOKEN = 'keeper://API_UID/field/password'
            }
            steps {
                sh 'ksm exec -- ./deploy.sh'
            }
        }
    }
}
```

### CircleCI

```yaml
version: 2.1

jobs:
  test:
    docker:
      - image: python:3.11
    environment:
      DB_HOST: keeper://REC_UID/field/host
      DB_USER: keeper://REC_UID/field/login
      DB_PASS: keeper://REC_UID/field/password
    steps:
      - checkout
      - run: pip install keeper-secrets-manager-cli pytest
      - run: ksm exec -- pytest tests/

  deploy:
    docker:
      - image: ubuntu:22.04
    environment:
      DEPLOY_KEY: keeper://KEY_UID/file/id_rsa
      API_TOKEN: keeper://API_UID/field/password
    steps:
      - checkout
      - run: apt-get update && apt-get install -y python-pip
      - run: pip install keeper-secrets-manager-cli
      - run: ksm exec -- ./deploy.sh

workflows:
  build-and-deploy:
    jobs:
      - test
      - deploy:
          requires:
            - test
          filters:
            branches:
              only: main
```

## Cloud Platforms

### AWS Lambda

```python
# handler.py
import os
import subprocess

def lambda_handler(event, context):
    # KSM automatically resolves keeper:// notation in environment
    db_host = os.getenv('DB_HOST')  # keeper://REC_UID/field/host
    db_user = os.getenv('DB_USER')  # keeper://REC_UID/field/login
    db_pass = os.getenv('DB_PASS')  # keeper://REC_UID/field/password

    # Use secrets directly
    import psycopg2
    conn = psycopg2.connect(
        host=db_host,
        user=db_user,
        password=db_pass
    )
```

**CloudFormation Template:**

```yaml
Resources:
  LambdaFunction:
    Type: AWS::Lambda::Function
    Properties:
      Runtime: python.11
      Handler: handler.lambda_handler
      Code:
        ZipFile: |
          import os
          def lambda_handler(event, context):
            db_pass = os.getenv('DB_PASS')
            return {'statusCode': 200}
      Environment:
        Variables:
          DB_HOST: "keeper://REC_UID/field/host"
          DB_USER: "keeper://REC_UID/field/login"
          DB_PASS: "keeper://REC_UID/field/password"
          KSM_CONFIG: !Sub '{{resolve:secretsmanager:ksm-config:SecretString}}'
```

### AWS ECS Task

```json
{
  "family": "my-app",
  "containerDefinitions": [
    {
      "name": "app",
      "image": "myapp:latest",
      "environment": [
        {
          "name": "DB_HOST",
          "value": "keeper://REC_UID/field/host"
        },
        {
          "name": "DB_USER",
          "value": "keeper://REC_UID/field/login"
        },
        {
          "name": "DB_PASS",
          "value": "keeper://REC_UID/field/password"
        }
      ],
      "secrets": [
        {
          "name": "KSM_CONFIG",
          "valueFrom": "arn:aws:secretsmanager:region:account:secret:ksm-config"
        }
      ],
      "command": ["ksm", "exec", "--", "/start.sh"]
    }
  ]
}
```

## Configuration File Templates

### Environment File Template (.env.keeper)

```text
# Database
DB_HOST=keeper://DB_UID/field/host
DB_PORT=keeper://DB_UID/field/port
DB_USER=keeper://DB_UID/field/login
DB_PASS=keeper://DB_UID/field/password
DB_NAME=myapp_db

# API Keys
STRIPE_KEY=keeper://STRIPE_UID/field/password
GITHUB_TOKEN=keeper://GITHUB_UID/field/password

# Certificates
SSL_CERT=keeper://CERT_UID/file/cert.pem
SSL_KEY=keeper://KEY_UID/file/key.pem
```

Generate with:

```bash
ksm interpolate --in-file .env.keeper --out-file .env.local
```

### YAML Config Template (config.keeper.yaml)

```yaml
database:
  host: keeper://DB_UID/field/host
  port: keeper://DB_UID/field/port
  user: keeper://DB_UID/field/login
  password: keeper://DB_UID/field/password
  database: myapp_db

api:
  base_url: keeper://API_UID/field/url
  key: keeper://API_UID/field/password
  token: keeper://API_UID/custom_field/AccessToken

ssl:
  certificate: keeper://CERT_UID/file/cert.pem
  key: keeper://KEY_UID/file/key.pem
```

Generate with:

```bash
ksm interpolate --in-file config.keeper.yaml --out-file config.yaml
```

## Best Practices

1. **Use environment variables** - Better than hardcoding UIDs in code
2. **Keep templates in git** - `.keeper.yaml`, `.env.keeper` safe to commit
3. **Never commit resolved configs** - `.env.local`, `config.yaml` in `.gitignore`
4. **One profile per env** - Separate production, staging, dev profiles
5. **Validate at startup** - Test KSM access with `ksm secret list` in init
6. **Log resolution** - Add debug output to verify secrets are resolving
7. **Handle failures gracefully** - `ksm exec` returns non-zero on auth failure
