# 🤝 Guide de Contribution

## Convention Commits

Format: `type(scope): description`

**Types** :
- `feat` : Nouvelle fonctionnalité
- `fix` : Correction bug
- `docs` : Documentation
- `refactor` : Refactoring code
- `test` : Ajout tests
- `ci` : Modification CI/CD

**Exemples** :
```
feat(vpc): add security groups for inter-VPC traffic
fix(rds): correct backup retention period to 7 days
docs(architecture): update network topology diagram
ci(terraform): add automated plan on pull request
```

---

## Workflow Git

### 1. Créer branche feature

```bash
# G3 - Architecture
git checkout -b feature/g3-transit-gateway

# G4 - VPC
git checkout -b feature/g4-vpc-module

# G5 - Services
git checkout -b feature/g5-rds-s3-iam

# G6 - CI/CD
git checkout -b feature/g6-api-cicd
```

### 2. Développer et commiter

```bash
# Faire vos modifications
git add .
git commit -m "feat(vpc): implement security groups module"
```

### 3. Push et Pull Request

```bash
git push origin feature/g4-vpc-module
# Créer PR sur GitHub
# Demander review autres groupes
```

---

## Code Review

Toute Pull Request requiert :
- ✅ Review par au moins 1 membre d'un autre groupe
- ✅ Tests passent (terraform validate, pytest)
- ✅ Documentation à jour

---

## Tests Avant Push

```bash
# Terraform
terraform validate
terraform fmt -check -recursive

# Python
pytest tests/ -v

# Pre-commit hooks
pre-commit run --all-files
```

---

## Structure Branches

```
main (production - protégée)
  │
  ├── develop (intégration)
  │   │
  │   ├── feature/g3-transit-gateway
  │   ├── feature/g4-vpc-module
  │   ├── feature/g5-rds-s3-iam
  │   └── feature/g6-api-cicd
```

---

**Merci de contribuer au projet CDNU Cloud !** 🚀
