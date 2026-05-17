# Backup et Restore

## RDS Backups
- Automatique: Quotidien (7 jours retention)
- Manuel: Snapshots on-demand

## Restore RDS
```bash
aws rds restore-db-instance-from-db-snapshot \
  --db-instance-identifier cdnu-cloud-postgres-restored \
  --db-snapshot-identifier snapshot-name
```

## S3 Versioning
Activé sur tous les buckets. Restore:
```bash
aws s3api list-object-versions --bucket cdnu-cloud-xxx
aws s3api get-object --bucket cdnu-cloud-xxx --key file --version-id xxx
```

## Terraform State
Backend S3 avec versioning activé.
