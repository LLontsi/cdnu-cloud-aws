# Déploiement Manuel

## Prérequis
- Terraform 1.7+
- AWS CLI configuré
- Docker installé

## Étapes

### 1. Configuration
```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars
# Éditer terraform.tfvars
```

### 2. Déploiement Infrastructure
```bash
terraform init
terraform plan
terraform apply
```

### 3. Déploiement API
```bash
cd ../api
docker build -t cdnu-cloud-api:latest .
# Push vers ECR
# Deploy ECS
```

Durée totale: 25-30 minutes
