# Configuration GitHub Secrets

## Secrets Requis

Aller dans: Settings → Secrets and variables → Actions

Ajouter:
- `AWS_ACCESS_KEY_ID`: Clé d'accès AWS
- `AWS_SECRET_ACCESS_KEY`: Clé secrète AWS
- `AWS_REGION`: eu-central-1
- `AWS_ACCOUNT_ID`: Votre Account ID

## Création Access Keys AWS
```bash
aws iam create-access-key --user-name github-actions
```

Stocker de manière sécurisée !
