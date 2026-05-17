# Optimisation des Coûts

## Coûts Actuels (~$560/mois)

| Service | Coût | Optimisation Possible |
|---------|------|----------------------|
| NAT Gateway | $385 | Supprimer si pas d'accès sortant → -$385 |
| Transit Gateway | $45 | Nécessaire |
| ECS Fargate | $33 | Fargate Spot → -70% = -$23 |
| RDS | $15 | Reserved Instance → -40% = -$6 |
| ALB | $25 | Nécessaire |
| EC2 | $0 | Free Tier (1 an) |
| Autres | $57 | S3 Lifecycle → -60% = -$20 |

## Recommandations

### Court Terme
1. **Supprimer NAT Gateways**: -$385/mois
2. **Fargate Spot**: -$23/mois
3. **S3 Intelligent-Tiering**: -$20/mois

**Total économies: -$428/mois → Coût final: ~$132/mois**

### Moyen Terme
4. Reserved Instances RDS (1 an): -$6/mois
5. Savings Plans Compute: -20%

### Long Terme
6. RDS Aurora Serverless v2
7. Lambda au lieu d'ECS pour faible charge
8. CloudFront CDN pour static assets

## S3 Lifecycle Déjà Implémenté
- Transition Glacier: 30/90/180 jours
- Suppression anciennes versions: 90 jours
- Cleanup uploads incomplets: 7 jours

**Économie attendue: 60-70% sur S3**
