# Documentation CDNU Cloud

Documentation complète du projet d'infrastructure AWS multi-région.

## Structure

- **architecture/**: Architecture technique
  - architecture-overview.md
  - networking.md
  - security.md
  - diagrams/: Diagrammes (voir PDFs LaTeX)

- **deployment/**: Guides de déploiement
  - manual-deployment.md
  - cicd-deployment.md

- **operations/**: Opérations et maintenance
  - monitoring.md
  - backup-restore.md
  - troubleshooting.md

- **setup/**: Configuration initiale
  - prerequisites.md
  - aws-account-setup.md
  - terraform-installation.md
  - github-secrets.md

- **cost-optimization.md**: Optimisation des coûts

## Documentation LaTeX

Pour documentation complète avec diagrammes:
```bash
cd ../docs  # Dossier avec fichiers .tex
make all
```

Fichiers générés:
- 00-guide-principal.pdf
- 01-architecture-reseau.pdf
- 02-securite.pdf

## Démarrage Rapide

1. Lire `setup/prerequisites.md`
2. Configurer AWS: `setup/aws-account-setup.md`
3. Déployer: `deployment/manual-deployment.md`
4. Monitorer: `operations/monitoring.md`

## Support

- Issues GitHub
- Documentation AWS: docs.aws.amazon.com
- Terraform Registry: registry.terraform.io
