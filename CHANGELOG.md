# Changelog

Toutes les modifications notables de ce projet seront documentées dans ce fichier.

Le format est basé sur [Keep a Changelog](https://keepachangelog.com/fr/1.0.0/),
et ce projet adhère au [Semantic Versioning](https://semver.org/lang/fr/).

---

## [1.0.0] - 2026-05-12

### Added
- Infrastructure complète pour 11 CDNU camerounais
- Transit Gateway en architecture hub-and-spoke
- 11 VPC interconnectés avec NAT Gateway
- RDS PostgreSQL Multi-AZ avec politiques de backup
- S3 buckets avec lifecycle rules et versioning
- IAM rôles et policies (Admin, Developer, CI/CD)
- API FastAPI "État des Services"
- CI/CD avec GitHub Actions (plan, apply, deploy)
- Documentation architecture complète
- Tests d'intégration infrastructure

### Infrastructure
- 11× EC2 t3.micro instances
- Transit Gateway (11 attachments)
- RDS PostgreSQL 15.4
- S3 buckets avec encryption
- CloudWatch monitoring
- Secrets Manager pour credentials

---

## [0.1.0] - 2026-05-01

### Added
- Structure projet initiale
- Modules Terraform de base
- Configuration CI/CD
