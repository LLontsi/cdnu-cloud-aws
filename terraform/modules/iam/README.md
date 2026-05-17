# Module IAM (G5)

Module Terraform pour la gestion centralisée des rôles et policies IAM du projet CDNU.

## Rôles Créés

### 1. **EC2 Instance Role**
Rôle assumé par les instances EC2 des CDNU.

**Permissions** :
- ✅ Accès S3 (buckets CDNU)
- ✅ CloudWatch Logs/Metrics
- ✅ Systems Manager (SSM)
- ✅ RDS Connect
- ✅ Secrets Manager (lecture)

**Usage** :
```hcl
resource "aws_instance" "main" {
  iam_instance_profile = module.iam.ec2_instance_profile_name
}
```

---

### 2. **ECS Task Execution Role**
Rôle utilisé par ECS pour démarrer les conteneurs.

**Permissions** :
- ✅ Pull images depuis ECR
- ✅ Écriture CloudWatch Logs
- ✅ Lecture Secrets Manager
- ✅ Décryptage KMS

**Usage** :
```hcl
resource "aws_ecs_task_definition" "main" {
  execution_role_arn = module.iam.ecs_task_execution_role_arn
}
```

---

### 3. **ECS Task Role**
Rôle assumé par les conteneurs ECS au runtime.

**Permissions** :
- ✅ Accès S3 (GET/PUT/DELETE)
- ✅ RDS DescribeDBInstances
- ✅ CloudWatch Logs

**Usage** :
```hcl
resource "aws_ecs_task_definition" "main" {
  task_role_arn = module.iam.ecs_task_role_arn
}
```

---

### 4. **Lambda Execution Role**
Rôle pour fonctions Lambda.

**Permissions** :
- ✅ Execution basique (logs)
- ✅ VPC Access (ENI)

**Usage** :
```hcl
resource "aws_lambda_function" "main" {
  role = module.iam.lambda_role_arn
}
```

---

### 5. **CI/CD Role**
Rôle assumé par GitHub Actions pour déploiement.

**Permissions** :
- ✅ Push images ECR
- ✅ Update ECS services
- ✅ Update Lambda functions
- ✅ Deploy vers S3
- ✅ IAM PassRole (pour ECS)

**Configuration GitHub Actions** :
```yaml
- name: Configure AWS Credentials
  uses: aws-actions/configure-aws-credentials@v4
  with:
    role-to-assume: ${{ secrets.AWS_CICD_ROLE_ARN }}
    aws-region: eu-central-1
```

---

### 6. **Developer Role**
Rôle pour développeurs (lecture + debug).

**Permissions** :
- ✅ Lecture seule (EC2, RDS, S3, ECS, Lambda)
- ✅ Logs CloudWatch (lecture)
- ✅ SSM Session Manager (debug)
- ✅ X-Ray traces
- ⛔ Pas de modification ressources

**Assume Role** :
```bash
aws sts assume-role \
  --role-arn arn:aws:iam::ACCOUNT:role/cdnu-cloud-developer-role \
  --role-session-name dev-session
```

---

### 7. **Admin Role**
Rôle administrateur avec MFA obligatoire.

**Permissions** :
- ✅ Accès complet **AVEC MFA**
- ✅ Lecture seule **SANS MFA**
- ⛔ Actions destructrices bloquées sans MFA

**Sécurité** :
- Delete EC2/RDS/S3/IAM → **MFA requis**
- Read-only → Aucun MFA

---

## Architecture Sécurité

```
┌─────────────────────────────────────────────┐
│             Principe du Moindre             │
│               Privilège (PoLP)              │
├─────────────────────────────────────────────┤
│                                             │
│  EC2 Role      → Accès S3 + RDS + Logs     │
│  ECS Role      → Accès S3 + Logs           │
│  Lambda Role   → VPC + Logs                │
│  CI/CD Role    → Deploy uniquement         │
│  Developer     → Read-Only + Debug         │
│  Admin         → Full (MFA requis)         │
│                                             │
└─────────────────────────────────────────────┘
```

---

## Policies JSON

Les policies sont dans `policies/` :

- `ec2-policy.json` - Permissions EC2
- `cicd-policy.json` - Permissions CI/CD
- `developer-policy.json` - Permissions développeur
- `admin-policy.json` - Permissions admin avec MFA

---

## Usage

```hcl
module "iam" {
  source = "./modules/iam"
  
  project_name = "cdnu-cloud"
  
  cicd_trust_principal_arn      = "arn:aws:iam::ACCOUNT:user/github-actions"
  developer_trust_principal_arn = "arn:aws:iam::ACCOUNT:user/developers"
  admin_trust_principal_arn     = "arn:aws:iam::ACCOUNT:user/admins"
}

# Utilisation dans compute
module "compute" {
  source = "./modules/compute"
  
  iam_instance_profile = module.iam.ec2_instance_profile_name
}
```

---

## Outputs

- `ec2_instance_profile_name` - Pour EC2
- `ecs_task_execution_role_arn` - Pour ECS execution
- `ecs_task_role_arn` - Pour ECS runtime
- `lambda_role_arn` - Pour Lambda
- `cicd_role_arn` - Pour GitHub Actions
- `developer_role_arn` - Pour développeurs
- `admin_role_arn` - Pour admins

---

## Sécurité

### ✅ Bonnes Pratiques Implémentées

1. **Least Privilege** : Chaque rôle a le minimum de permissions
2. **MFA pour Admin** : Actions destructrices = MFA obligatoire
3. **Pas de wildcard ARN** : Ressources ciblées quand possible
4. **Conditions** : Restrictions supplémentaires (tags, MFA)
5. **Rotation** : Pas de credentials statiques
6. **Audit** : CloudTrail log toutes les actions IAM

### ⚠️ À Faire en Production

- [ ] Restreindre les trust principals (pas `*`)
- [ ] Activer CloudTrail pour audit
- [ ] Configurer AWS Config pour compliance
- [ ] Mettre en place alertes sur actions sensibles
- [ ] Rotation régulière des access keys

---

## Troubleshooting

### "Access Denied" sur EC2
→ Vérifier l'instance profile est attaché
```bash
aws ec2 describe-instances --instance-id i-xxx --query 'Reservations[0].Instances[0].IamInstanceProfile'
```

### "Unable to assume role" 
→ Vérifier trust policy
```bash
aws iam get-role --role-name cdnu-cloud-ec2-role --query 'Role.AssumeRolePolicyDocument'
```

### "PassRole denied" en CI/CD
→ Vérifier permission IAM PassRole dans cicd-policy.json
