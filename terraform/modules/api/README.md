# Module API Infrastructure (G6)

Module Terraform pour déployer l'infrastructure API des CDNU sur AWS ECS Fargate avec ALB et auto-scaling.

## Architecture

```
Internet
    ↓
┌─────────────────────────────────────────┐
│  Application Load Balancer (ALB)       │
│  - HTTPS (port 443)                    │
│  - HTTP → HTTPS redirect               │
│  - TLS 1.3                             │
└─────────────────────────────────────────┘
    ↓
┌─────────────────────────────────────────┐
│  Target Group                           │
│  - Health checks: /health               │
│  - Sticky sessions                      │
└─────────────────────────────────────────┘
    ↓
┌─────────────────────────────────────────┐
│  ECS Service (Fargate)                  │
│  - 2 tasks (min: 1, max: 10)           │
│  - Auto-scaling: CPU/Memory/Requests    │
│  - Circuit Breaker enabled              │
└─────────────────────────────────────────┘
    ↓
┌─────────────────────────────────────────┐
│  ECS Task Definition                    │
│  - FastAPI container                    │
│  - CPU: 512 / Memory: 1024 MB          │
│  - Health check: /health                │
└─────────────────────────────────────────┘
    ↓
┌─────────────────────────────────────────┐
│  ECR Repository                         │
│  - Image scanning on push               │
│  - Lifecycle: keep 10 images            │
└─────────────────────────────────────────┘
```

---

## Composants

### 1. **ECS Cluster**
- Fargate launch type (serverless)
- Container Insights activé
- Capacity Providers: 20% Fargate + 80% Fargate Spot (économies)

### 2. **Task Definition**
- **CPU**: 512 (0.5 vCPU)
- **Memory**: 1024 MB (1 GB)
- **Container**: FastAPI sur port 8000
- **Health check**: `curl -f http://localhost:8000/health`
- **Environment variables**: ENVIRONMENT, LOG_LEVEL, DATABASE_HOST
- **Secrets**: DATABASE_PASSWORD (depuis Secrets Manager)

### 3. **ECS Service**
- **Desired count**: 2 tasks
- **Min/Max**: 1-10 tasks
- **Deployment**: Rolling update (100-200%)
- **Circuit Breaker**: Rollback automatique en cas d'échec
- **Health check grace period**: 60 secondes

### 4. **Application Load Balancer**
- **Type**: Application (Layer 7)
- **Scheme**: Internet-facing
- **Listeners**: 
  - HTTP (80) → Redirect HTTPS
  - HTTPS (443) → Forward to target group
- **SSL Policy**: TLS 1.3 uniquement
- **Access logs**: Activés vers S3

### 5. **Auto Scaling**
Trois politiques de scaling :

**Policy 1 - CPU** :
- Target: 70% CPU utilization
- Scale out: 60s cooldown
- Scale in: 300s cooldown

**Policy 2 - Memory** :
- Target: 80% Memory utilization
- Scale out: 60s cooldown
- Scale in: 300s cooldown

**Policy 3 - Request Count** :
- Target: 1000 requests/target
- Scale out: 60s cooldown
- Scale in: 300s cooldown

### 6. **ECR Repository**
- **Image scanning**: Activé au push
- **Encryption**: AES256
- **Lifecycle policy**:
  - Garder les 10 dernières images
  - Supprimer images untagged après 7 jours

---

## CloudWatch Alarms

### ALB Alarms
1. **Unhealthy Targets**: Alert si targets unhealthy > 0
2. **High Response Time**: Alert si response time > 1 seconde
3. **HTTP 5XX**: Alert si > 10 erreurs 5XX en 5 minutes

### ECR Alarms
1. **Critical Vulnerabilities**: Alert si vulnérabilités critiques détectées

---

## Usage

```hcl
module "api" {
  source = "./modules/api"
  
  project_name = "cdnu-cloud"
  
  # Networking
  vpc_id              = module.vpc.vpc_id
  public_subnet_ids   = module.vpc.public_subnet_ids
  private_subnet_ids  = module.vpc.private_subnet_ids
  api_security_group_id = aws_security_group.api.id
  alb_security_group_id = aws_security_group.alb.id
  
  # ECS Configuration
  task_cpu       = "512"
  task_memory    = "1024"
  desired_count  = 2
  min_capacity   = 1
  max_capacity   = 10
  
  # IAM Roles
  ecs_task_execution_role_arn = module.iam.ecs_task_execution_role_arn
  ecs_task_role_arn           = module.iam.ecs_task_role_arn
  
  # Database
  database_endpoint               = module.database.endpoint
  database_credentials_secret_arn = module.database.credentials_secret_arn
  
  # ALB
  certificate_arn    = aws_acm_certificate.main.arn
  alb_logs_bucket_id = module.storage.logs_bucket_id
}
```

---

## Déploiement d'une nouvelle version

### Via GitHub Actions (recommandé)

```yaml
- name: Deploy to ECS
  run: |
    aws ecs update-service \
      --cluster ${{ secrets.ECS_CLUSTER_NAME }} \
      --service ${{ secrets.ECS_SERVICE_NAME }} \
      --force-new-deployment
```

### Manuellement

```bash
# 1. Build l'image Docker
docker build -t cdnu-cloud-api:latest .

# 2. Tag pour ECR
aws ecr get-login-password --region eu-central-1 | docker login --username AWS --password-stdin ACCOUNT.dkr.ecr.eu-central-1.amazonaws.com
docker tag cdnu-cloud-api:latest ACCOUNT.dkr.ecr.eu-central-1.amazonaws.com/cdnu-cloud-api:latest

# 3. Push vers ECR
docker push ACCOUNT.dkr.ecr.eu-central-1.amazonaws.com/cdnu-cloud-api:latest

# 4. Force deployment ECS
aws ecs update-service \
  --cluster cdnu-cloud-cluster \
  --service cdnu-cloud-api-service \
  --force-new-deployment
```

---

## Monitoring

### Métriques Importantes

**ECS Service**:
- `CPUUtilization`: Utilisation CPU (target: 70%)
- `MemoryUtilization`: Utilisation mémoire (target: 80%)
- `RunningTaskCount`: Nombre de tasks actives

**ALB**:
- `TargetResponseTime`: Temps de réponse moyen
- `RequestCount`: Nombre de requêtes
- `HTTPCode_Target_5XX_Count`: Erreurs serveur
- `UnHealthyHostCount`: Nombre de targets unhealthy

**ECR**:
- `ImageScanFindings`: Vulnérabilités détectées

### Dashboard CloudWatch

Créer un dashboard avec :
```bash
aws cloudwatch put-dashboard \
  --dashboard-name cdnu-api-dashboard \
  --dashboard-body file://dashboard.json
```

---

## Coût Estimé

### ECS Fargate

| Ressource | Quantité | Coût/h | Coût/mois |
|-----------|----------|--------|-----------|
| vCPU (0.5) | 2 tasks | $0.02048 | ~$30 |
| Memory (1GB) | 2 tasks | $0.00224 | ~$3.30 |
| **Total Fargate** | | | **~$33/mois** |

### Application Load Balancer

| Ressource | Coût |
|-----------|------|
| ALB fixe | $16.20/mois |
| LCU (trafic) | Variable |
| **Total ALB** | **~$20-30/mois** |

### Autres

- **ECR**: $0.10/GB/mois (images)
- **CloudWatch Logs**: $0.50/GB ingéré
- **Data Transfer**: $0.09/GB sortant

**COÛT TOTAL ESTIMÉ**: ~$60-80/mois (pour 2 tasks permanentes)

---

## Optimisation Coûts

### Utiliser Fargate Spot (jusqu'à 70% d'économies)

Le module utilise déjà 80% Fargate Spot :
```hcl
capacity_provider = "FARGATE_SPOT"
weight            = 4  # 80%
```

### Réduire le nombre de tasks

Pour dev/test :
```hcl
desired_count = 1
min_capacity  = 1
max_capacity  = 3
```

**Économie**: ~50% sur Fargate

### Utiliser Savings Plans

- Fargate Compute Savings Plans: -20% (1 an)
- Fargate Compute Savings Plans: -40% (3 ans)

---

## Troubleshooting

### Tasks ne démarrent pas

```bash
# Vérifier les logs
aws logs tail /ecs/cdnu-cloud-api --follow

# Vérifier le service
aws ecs describe-services \
  --cluster cdnu-cloud-cluster \
  --services cdnu-cloud-api-service
```

### Erreurs 503 sur ALB

→ Aucune task healthy
```bash
# Vérifier target health
aws elbv2 describe-target-health \
  --target-group-arn <ARN>
```

### Health check échoue

→ Vérifier l'endpoint `/health` retourne 200:
```bash
# Depuis une task
curl http://localhost:8000/health
```

### Image pull errors

→ Vérifier les permissions ECR dans le rôle task execution

---

## Sécurité

### ✅ Bonnes Pratiques Implémentées

1. **Tasks en subnets privés** (pas d'IP publique)
2. **ALB en subnets publics** (seul point d'entrée)
3. **HTTPS uniquement** (TLS 1.3)
4. **Security Groups restrictifs**
5. **Image scanning ECR** (détection vulnérabilités)
6. **Secrets dans Secrets Manager** (pas en plaintext)
7. **IAM roles** (least privilege)
8. **CloudWatch Logs** (audit trail)

### ⚠️ À Faire en Production

- [ ] Configurer WAF sur ALB
- [ ] Activer GuardDuty
- [ ] Configurer rate limiting
- [ ] Mettre en place DDoS protection (Shield)
- [ ] Activer X-Ray pour tracing
- [ ] Configurer alertes SNS

---

## Variables

| Variable | Description | Défaut |
|----------|-------------|--------|
| `task_cpu` | CPU pour task ECS | 512 |
| `task_memory` | Mémoire pour task ECS (MB) | 1024 |
| `desired_count` | Nombre de tasks | 2 |
| `min_capacity` | Min tasks (auto-scaling) | 1 |
| `max_capacity` | Max tasks (auto-scaling) | 10 |

## Outputs

| Output | Description |
|--------|-------------|
| `alb_dns_name` | DNS du ALB (à utiliser pour Route53) |
| `ecs_cluster_name` | Nom du cluster ECS |
| `ecr_repository_url` | URL ECR pour push images |
| `ecs_service_name` | Nom du service ECS |
