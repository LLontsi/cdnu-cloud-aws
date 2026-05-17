# Architecture Overview - CDNU Cloud

## Vue d'Ensemble
Infrastructure AWS multi-région pour 11 CDNUs au Cameroun.

## Composants
- 11 VPC répartis sur 3 régions AWS
- Transit Gateway pour interconnexion
- RDS PostgreSQL centralisé
- API FastAPI sur ECS Fargate
- Monitoring CloudWatch

## Régions
- eu-central-1: 4 CDNUs
- eu-west-3: 4 CDNUs  
- eu-west-1: 3 CDNUs

Voir les autres fichiers pour plus de détails.
