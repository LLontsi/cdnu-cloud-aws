# Monitoring

## CloudWatch Dashboard
Accessible: Console AWS → CloudWatch → Dashboards → cdnu-cloud-health

Métriques:
- EC2 CPU/Network
- RDS CPU/Connections/Storage
- ECS CPU/Memory/Tasks
- ALB Requests/ResponseTime/Errors

## Alarmes SNS
- Critical: Email + SMS
- Warning: Email
- Info: Email

## Logs
- /ecs/cdnu-cloud-api
- /aws/rds/instance/cdnu-cloud-postgres
- VPC Flow Logs (à activer)
