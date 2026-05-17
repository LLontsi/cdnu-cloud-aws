# Module Monitoring (G6)

Module Terraform pour le monitoring centralisé de l'infrastructure CDNU avec CloudWatch, SNS et alarmes.

## Architecture

```
┌─────────────────────────────────────────────┐
│         CloudWatch Metrics                  │
│  EC2 | RDS | ECS | ALB | Custom            │
└─────────────────────────────────────────────┘
              ↓
┌─────────────────────────────────────────────┐
│         CloudWatch Alarms                   │
│  - CPU High                                 │
│  - Memory High                              │
│  - Disk Low                                 │
│  - Error Rate High                          │
│  - Response Time High                       │
└─────────────────────────────────────────────┘
              ↓
┌─────────────────────────────────────────────┐
│         SNS Topics                          │
│  - Critical (email + SMS)                   │
│  - Warning (email)                          │
│  - Info (email)                             │
└─────────────────────────────────────────────┘
              ↓
┌─────────────────────────────────────────────┐
│         Notifications                       │
│  📧 Email                                   │
│  📱 SMS                                     │
└─────────────────────────────────────────────┘
```

---

## Composants

### 1. **SNS Topics**

Trois niveaux de sévérité :

**Critical** :
- Email + SMS
- Incidents nécessitant action immédiate
- Exemples : Service down, DB inaccessible, storage full

**Warning** :
- Email uniquement
- Problèmes à surveiller
- Exemples : CPU > 80%, memory > 85%

**Info** :
- Email uniquement
- Notifications informatives
- Exemples : Alarme résolue, déploiement réussi

### 2. **CloudWatch Alarms**

#### EC2 Alarms (par instance)
- **CPU High** : CPU > 80% pendant 10 min → Warning
- **Status Check Failed** : Health check échoué → Critical

#### RDS Alarms
- **CPU High** : CPU > 80% pendant 10 min → Warning
- **Storage Low** : Espace disque < 2 GB → Critical
- **Connections High** : > 80 connexions actives → Warning

#### ECS Alarms
- **CPU High** : CPU > 80% pendant 10 min → Warning
- **Memory High** : Memory > 85% pendant 10 min → Warning

#### Application Alarms
- **High Error Rate** : > 10 erreurs 500 en 5 min → Critical
- **DB Connection Errors** : > 5 erreurs en 1 min → Critical

### 3. **CloudWatch Dashboard**

Dashboard interactif avec widgets :

**Section EC2** :
- CPU Utilization (toutes instances)
- Network Traffic

**Section RDS** :
- CPU Utilization
- Database Connections
- Free Storage Space

**Section ECS** :
- CPU Utilization
- Memory Utilization
- Running Task Count

**Section ALB** :
- Request Count
- Response Time
- HTTP Errors (4XX, 5XX)

**Section Application** :
- Application Errors
- Database Connection Errors

### 4. **Log Groups**

Deux log groups centralisés :

- `/cdnu/PROJECT/application` : Logs applicatifs (retention 30j)
- `/cdnu/PROJECT/infrastructure` : Logs infrastructure (retention 90j)

### 5. **Metric Filters**

Extraction de métriques depuis logs :

- **Error500Count** : Pattern `5?? *`
- **Error400Count** : Pattern `4?? *`
- **DatabaseConnectionErrors** : Pattern `*connection* *failed*`

### 6. **CloudWatch Insights Queries**

Requêtes pré-définies :

- **error-analysis** : Analyse des erreurs par tranche de 5 min
- **slow-requests** : Requêtes > 1 seconde
- **top-endpoints** : Top 20 endpoints les plus appelés

### 7. **Budget Alerts**

Alertes de coûts AWS :

- **80% du budget** : Email d'avertissement
- **100% du budget** : Email critique

---

## Usage

```hcl
module "monitoring" {
  source = "./modules/monitoring"
  
  project_name = "cdnu-cloud"
  
  # Alertes
  alert_email = "admin@cdnu-yaounde.cm"
  alert_phone = "+237612345678"  # Optionnel
  
  # Ressources à monitorer
  ec2_instance_ids = {
    yaounde    = "i-1234567890abcdef0"
    douala     = "i-0987654321fedcba0"
    buea       = "i-abcdef1234567890a"
    ngaoundere = "i-fedcba0987654321f"
  }
  
  rds_instance_id = "cdnu-cloud-postgres"
  
  ecs_cluster_name = "cdnu-cloud-cluster"
  ecs_service_name = "cdnu-cloud-api-service"
  
  alb_arn_suffix         = module.api.alb_arn_suffix
  target_group_arn_suffix = module.api.target_group_arn_suffix
  
  # Dashboard
  dashboard_name = "cdnu-cloud-health"
  
  # Budget
  enable_cost_alerts  = true
  monthly_budget_limit = "500"
}
```

---

## Configuration des Notifications

### Confirmer l'abonnement Email

Après le déploiement, AWS envoie un email de confirmation :

1. Vérifier votre boîte mail
2. Cliquer sur "Confirm subscription"
3. Les alertes commenceront à arriver

### Format SMS

Le numéro de téléphone doit être au format international :

```
+33612345678   # France
+237670123456  # Cameroun
+1234567890    # US
```

---

## Alarmes Composites

Combine plusieurs alarmes pour détecter un problème systémique :

```hcl
enable_composite_alarms = true
```

**Exemple** : `service-completely-down`
- Déclenché si : Unhealthy Targets **ET** High Error Rate
- Évite les fausses alertes

---

## CloudWatch Insights

### Analyse des erreurs

```
fields @timestamp, @message
| filter @message like /ERROR/
| stats count() by bin(5m)
```

### Requêtes lentes

```
fields @timestamp, @message, duration
| filter duration > 1000
| sort duration desc
| limit 100
```

### Top endpoints

```
fields @timestamp, endpoint, method
| stats count() as request_count by endpoint, method
| sort request_count desc
| limit 20
```

---

## Coût Estimé

### CloudWatch

| Ressource | Quantité | Coût/mois |
|-----------|----------|-----------|
| Métriques custom | 10 | $3 |
| Alarmes | 20 | $10 |
| Dashboard | 1 | $3 |
| Log ingestion | 10 GB | $5 |
| **Total CloudWatch** | | **~$21/mois** |

### SNS

| Ressource | Quantité | Coût/mois |
|-----------|----------|-----------|
| Email (gratuit) | Illimité | $0 |
| SMS | 100 messages | $5-10 |
| **Total SNS** | | **~$5-10/mois** |

**COÛT TOTAL ESTIMÉ** : ~$30/mois

---

## Optimisation Coûts

### Réduire la rétention des logs

```hcl
retention_in_days = 7  # Au lieu de 30
```

**Économie** : ~60%

### Désactiver les métriques inutiles

Commenter les alarmes non critiques :

```hcl
# resource "aws_cloudwatch_metric_alarm" "ec2_cpu_high" {
#   ...
# }
```

### Utiliser metric filters au lieu de custom metrics

Les metric filters sont gratuits, contrairement aux custom metrics.

---

## Troubleshooting

### Pas d'email reçu

→ Vérifier la confirmation SNS
```bash
aws sns list-subscriptions-by-topic \
  --topic-arn arn:aws:sns:REGION:ACCOUNT:cdnu-cloud-critical-alerts
```

### Alarme ne se déclenche pas

→ Vérifier les métriques
```bash
aws cloudwatch get-metric-statistics \
  --namespace AWS/EC2 \
  --metric-name CPUUtilization \
  --dimensions Name=InstanceId,Value=i-xxx \
  --start-time 2026-01-01T00:00:00Z \
  --end-time 2026-01-01T01:00:00Z \
  --period 300 \
  --statistics Average
```

### Dashboard vide

→ Vérifier que les ressources existent et envoient des métriques

### Trop d'alertes (alert fatigue)

→ Ajuster les seuils :
```hcl
threshold = 90  # Au lieu de 80
evaluation_periods = 3  # Au lieu de 2
```

---

## Bonnes Pratiques

### ✅ Implémenté

1. **Niveaux de sévérité** : Critical, Warning, Info
2. **Alertes actionnables** : Chaque alarme a une résolution claire
3. **Composite alarms** : Évite les fausses alertes
4. **Dashboard centralisé** : Vue d'ensemble rapide
5. **Log aggregation** : Tous les logs au même endroit
6. **Budget alerts** : Contrôle des coûts

### ⚠️ À Améliorer en Production

- [ ] Intégrer avec PagerDuty/OpsGenie
- [ ] Ajouter runbooks aux alarmes
- [ ] Configurer escalation policies
- [ ] Activer AWS X-Ray pour tracing
- [ ] Mettre en place on-call rotation
- [ ] Créer incident response playbooks

---

## Intégration avec Terraform

Passer les SNS topic ARNs aux autres modules :

```hcl
module "api" {
  # ...
  
  alarm_actions = [
    module.monitoring.critical_topic_arn,
    module.monitoring.warning_topic_arn
  ]
}

module "database" {
  # ...
  
  alarm_actions = [
    module.monitoring.critical_topic_arn
  ]
}
```

---

## Métriques Custom

Envoyer des métriques custom depuis votre application :

```python
import boto3

cloudwatch = boto3.client('cloudwatch')

cloudwatch.put_metric_data(
    Namespace='CDNU/Application',
    MetricData=[
        {
            'MetricName': 'CustomMetric',
            'Value': 123,
            'Unit': 'Count'
        }
    ]
)
```

---

## Variables

| Variable | Description | Défaut |
|----------|-------------|--------|
| `alert_email` | Email pour alertes | "" |
| `alert_phone` | Téléphone pour SMS | "" |
| `enable_cost_alerts` | Activer alertes budget | true |
| `monthly_budget_limit` | Budget mensuel (USD) | "500" |
| `dashboard_name` | Nom du dashboard | "" |

## Outputs

| Output | Description |
|--------|-------------|
| `critical_topic_arn` | ARN topic SNS Critical |
| `warning_topic_arn` | ARN topic SNS Warning |
| `dashboard_url` | URL du dashboard CloudWatch |
