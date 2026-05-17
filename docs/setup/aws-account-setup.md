# Configuration Compte AWS

## Création Compte
1. Aller sur aws.amazon.com
2. Créer un compte
3. Fournir carte de crédit

## Configuration CLI
```bash
aws configure
AWS Access Key ID: YOUR_KEY
AWS Secret Access Key: YOUR_SECRET
Default region: eu-central-1
```

## Vérification
```bash
aws sts get-caller-identity
```

## Activer Régions
- eu-central-1 (Francfort)
- eu-west-3 (Paris)
- eu-west-1 (Irlande)

## Budget Alerts
Créer une alerte budget dans AWS Budgets: $500/mois
