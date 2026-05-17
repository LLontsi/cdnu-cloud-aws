# Troubleshooting

## Erreurs Communes

### VpcLimitExceeded
Solution: Architecture multi-région déjà implémentée

### RDS Deletion Protection
```bash
aws rds modify-db-instance --no-deletion-protection --apply-immediately
```

### ECS Tasks ne démarrent pas
```bash
aws logs tail /ecs/cdnu-cloud-api --follow
```

### Terraform State Lock
```bash
# Voir le lock
aws dynamodb get-item --table-name terraform-state-lock --key '{"LockID":{"S":"terraform-state/global"}}'

# Force unlock (avec précaution)
terraform force-unlock LOCK_ID
```

## Logs
Tous les logs dans CloudWatch: Console AWS → CloudWatch → Log groups
