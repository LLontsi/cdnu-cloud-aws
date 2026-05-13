# 🏛️ CDNU Cloud AWS - Infrastructure 11 CDNU Camerounais

[![Terraform](https://img.shields.io/badge/Terraform-1.5+-623CE4?logo=terraform)](https://www.terraform.io/)
[![AWS](https://img.shields.io/badge/AWS-Cloud-FF9900?logo=amazonaws)](https://aws.amazon.com/)

> Infrastructure as Code pour 11 Centres de Développement du Numérique Universitaire

**Groupes** : G3 (Architecture) + G4 (IaC Réseau) + G5 (Services Managés) + G6 (CI/CD + API)  
**Score Visé** : 19-20/20

---

## 🎯 11 CDNU DÉPLOYÉS

| CDNU | VPC CIDR | Instance | Région |
|------|----------|----------|--------|
| Yaoundé | 10.0.0.0/16 | t3.micro | eu-central-1a |
| Douala | 10.1.0.0/16 | t3.micro | eu-central-1b |
| Buea | 10.2.0.0/16 | t3.micro | eu-central-1c |
| Ngaoundéré | 10.3.0.0/16 | t3.micro | eu-central-1a |
| Maroua | 10.4.0.0/16 | t3.micro | eu-central-1b |
| Garoua | 10.5.0.0/16 | t3.micro | eu-central-1c |
| Bamenda | 10.6.0.0/16 | t3.micro | eu-central-1a |
| Bafoussam | 10.7.0.0/16 | t3.micro | eu-central-1b |
| Bertoua | 10.8.0.0/16 | t3.micro | eu-central-1c |
| Ebolowa | 10.9.0.0/16 | t3.micro | eu-central-1a |
| Kribi | 10.10.0.0/16 | t3.micro | eu-central-1b |

---

## 🚀 DÉMARRAGE RAPIDE

```bash
# 1. Configuration AWS
aws configure

# 2. Backend S3
export AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
aws s3 mb s3://cdnu-terraform-state-$AWS_ACCOUNT_ID

# 3. Variables
cd terraform/environments/production
cp terraform.tfvars.example terraform.tfvars
nano terraform.tfvars  # Remplir TODO:

# 4. Déployer
terraform init
terraform apply
```

---

## 📋 RESPONSABILITÉS PAR GROUPE

### G3 - Architecture Haut Niveau
- `terraform/modules/transit-gateway/` - Hub central Transit Gateway
- `docs/architecture/` - Documentation architecture complète

### G4 - Infrastructure as Code (Réseau)
- `terraform/modules/vpc/` - VPC, subnets, NAT, routes, security
- `terraform/modules/compute/` - EC2 instances
- `terraform/main.tf` - Orchestration principale

### G5 - Services Managés
- `terraform/modules/database/` - RDS PostgreSQL Multi-AZ
- `terraform/modules/storage/` - S3 buckets avec lifecycle
- `terraform/modules/iam/` - Rôles et policies IAM

### G6 - CI/CD & Application Exemple
- `api/` - API FastAPI "État des Services"
- `.github/workflows/` - Pipelines CI/CD
- `terraform/modules/api/` - Infrastructure API (ECS/Lambda)

---

## 💰 ESTIMATION COÛTS

| Service | Quantité | Coût/mois |
|---------|----------|-----------|
| EC2 t3.micro | 11 | $0 (Free Tier) |
| Transit Gateway | 11 attachments | $40 |
| NAT Gateway | 1 | $32 |
| RDS PostgreSQL | 3× t3.micro | $45 |
| S3 | 550 GB | $12.65 |
| **TOTAL** | | **~$130/mois** |

**Avec Free Tier AWS Educate** : Couvert 1.5-2 mois

---

## 🧪 TESTS

```bash
# Validation Terraform
terraform validate
terraform fmt -check -recursive

# Tests API
cd api && pytest tests/ -v

# Tests infrastructure
cd tests/integration && pytest -v
```

---

## 🤝 WORKFLOW COLLABORATION

```
main (production)
  ├── develop
  │   ├── feature/g3-transit-gateway
  │   ├── feature/g4-vpc-module
  │   ├── feature/g5-rds-s3-iam
  │   └── feature/g6-api-cicd
```

**Convention commits** : `type(scope): description`

---

## 📖 DOCUMENTATION

- **docs/architecture/** - Architecture et design réseau
- **docs/setup/** - Guides installation
- **docs/deployment/** - Procédures déploiement

---

## 👥 ÉQUIPE

**Coordinateur Technique** : LONTSI LAMBOU RONALDINO (G4)

**Groupes** :
- G3 : Architecture haut niveau
- G4 : Infrastructure as Code (Réseau)
- G5 : Services managés
- G6 : CI/CD & Application exemple

---

## 📄 LICENCE

MIT License

---

**Projet** : Déploiement environnement cloud CDNU  
**Institutions** : Université de Yaoundé I / INP-ENSEEIHT Toulouse / ISAE-Supaero  
**Année** : 2026