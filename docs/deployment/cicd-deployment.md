# Déploiement CI/CD

## GitHub Actions

Workflows configurés dans `.github/workflows/`:
- `terraform-plan.yml`: Plan sur PR
- `terraform-apply.yml`: Apply sur merge main
- `api-deploy.yml`: Build et deploy API
- `tests.yml`: Tests unitaires

## Configuration

Secrets GitHub requis:
- AWS_ACCESS_KEY_ID
- AWS_SECRET_ACCESS_KEY
- AWS_REGION

## Déclenchement Automatique

Push sur `main` → Deploy automatique
