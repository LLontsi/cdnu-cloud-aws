# CDNU Cloud API

API REST FastAPI pour la gestion des Centres de Développement du Numérique Universitaire (CDNU).

## Stack Technique

- **Framework**: FastAPI 0.109.0
- **Database**: PostgreSQL (via SQLAlchemy 2.0)
- **Server**: Uvicorn (ASGI)
- **Container**: Docker
- **Testing**: Pytest

## Fonctionnalités

### Endpoints

**Health Checks**:
- `GET /health` - Simple health check
- `GET /api/v1/health` - Health check avec statut DB

**CDNU Management**:
- `POST /api/v1/cdnu` - Créer un CDNU
- `GET /api/v1/cdnu` - Lister tous les CDNUs
- `GET /api/v1/cdnu/{id}` - Obtenir un CDNU
- `PUT /api/v1/cdnu/{id}` - Mettre à jour un CDNU
- `DELETE /api/v1/cdnu/{id}` - Supprimer un CDNU

**Resource Management**:
- `POST /api/v1/cdnu/{id}/resources` - Créer une ressource
- `GET /api/v1/cdnu/{id}/resources` - Lister les ressources d'un CDNU

### Documentation API

- **Swagger UI**: `/api/docs`
- **ReDoc**: `/api/redoc`
- **OpenAPI JSON**: `/api/openapi.json`

## Installation Locale

### Prérequis

- Python 3.11+
- PostgreSQL 15+

### Setup

```bash
# Cloner le repo
cd api

# Créer environnement virtuel
python -m venv venv
source venv/bin/activate  # Linux/Mac
# ou
venv\Scripts\activate  # Windows

# Installer dépendances
pip install -r requirements.txt

# Variables d'environnement
export DATABASE_HOST=localhost
export DATABASE_PORT=5432
export DATABASE_NAME=cdnu_db
export DATABASE_USER=cdnu_admin
export DATABASE_PASSWORD=your_password
export ENVIRONMENT=development

# Lancer l'API
uvicorn app.main:app --reload
```

L'API est accessible sur `http://localhost:8000`

## Docker

### Build

```bash
docker build -t cdnu-cloud-api:latest .
```

### Run

```bash
docker run -d \
  -p 8000:8000 \
  -e DATABASE_HOST=your-rds-endpoint \
  -e DATABASE_PASSWORD=your-password \
  --name cdnu-api \
  cdnu-cloud-api:latest
```

## Tests

```bash
# Lancer tous les tests
pytest

# Avec coverage
pytest --cov=app --cov-report=html

# Test spécifique
pytest tests/test_main.py::test_health_check -v
```

## Structure du Projet

```
api/
├── app/
│   ├── __init__.py          # Package init
│   ├── main.py              # Application principale
│   ├── database.py          # Configuration DB
│   ├── models.py            # Modèles Pydantic & SQLAlchemy
│   └── crud.py              # Opérations CRUD
├── tests/
│   └── test_main.py         # Tests unitaires
├── Dockerfile               # Image Docker
├── requirements.txt         # Dépendances Python
└── README.md               # Cette doc
```

## Modèles de Données

### CDNU

```json
{
  "id": 1,
  "name": "yaounde",
  "city": "Yaoundé",
  "region": "Centre",
  "vpc_cidr": "10.0.0.0/16",
  "instance_id": "i-1234567890abcdef0",
  "public_ip": "52.29.123.45",
  "status": "active",
  "created_at": "2026-01-15T10:30:00Z",
  "updated_at": "2026-01-15T12:45:00Z"
}
```

### Resource

```json
{
  "id": 1,
  "cdnu_id": 1,
  "resource_type": "ec2",
  "resource_id": "i-1234567890abcdef0",
  "resource_arn": "arn:aws:ec2:eu-central-1:123456789012:instance/i-1234567890abcdef0",
  "status": "running",
  "metadata": "{\"size\": \"t3.micro\"}",
  "created_at": "2026-01-15T10:30:00Z",
  "updated_at": "2026-01-15T12:45:00Z"
}
```

## Exemples d'Utilisation

### Créer un CDNU

```bash
curl -X POST http://localhost:8000/api/v1/cdnu \
  -H "Content-Type: application/json" \
  -d '{
    "name": "yaounde",
    "city": "Yaoundé",
    "region": "Centre",
    "vpc_cidr": "10.0.0.0/16"
  }'
```

### Lister les CDNUs

```bash
curl http://localhost:8000/api/v1/cdnu
```

### Créer une ressource

```bash
curl -X POST http://localhost:8000/api/v1/cdnu/1/resources \
  -H "Content-Type: application/json" \
  -d '{
    "resource_type": "ec2",
    "resource_id": "i-1234567890abcdef0",
    "status": "running"
  }'
```

## Variables d'Environnement

| Variable | Description | Défaut |
|----------|-------------|--------|
| `DATABASE_HOST` | Hôte PostgreSQL | localhost |
| `DATABASE_PORT` | Port PostgreSQL | 5432 |
| `DATABASE_NAME` | Nom de la DB | cdnu_db |
| `DATABASE_USER` | Utilisateur DB | cdnu_admin |
| `DATABASE_PASSWORD` | Mot de passe DB | (requis) |
| `ENVIRONMENT` | Environnement | development |
| `LOG_LEVEL` | Niveau de log | INFO |

## Déploiement sur ECS

### 1. Build et Push vers ECR

```bash
# Login ECR
aws ecr get-login-password --region eu-central-1 | \
  docker login --username AWS --password-stdin \
  ACCOUNT.dkr.ecr.eu-central-1.amazonaws.com

# Build
docker build -t cdnu-cloud-api:latest .

# Tag
docker tag cdnu-cloud-api:latest \
  ACCOUNT.dkr.ecr.eu-central-1.amazonaws.com/cdnu-cloud-api:latest

# Push
docker push ACCOUNT.dkr.ecr.eu-central-1.amazonaws.com/cdnu-cloud-api:latest
```

### 2. Update ECS Service

```bash
aws ecs update-service \
  --cluster cdnu-cloud-cluster \
  --service cdnu-cloud-api-service \
  --force-new-deployment \
  --region eu-central-1
```

## Monitoring

### Logs

```bash
# Logs Docker local
docker logs cdnu-api -f

# Logs CloudWatch (ECS)
aws logs tail /ecs/cdnu-cloud-api --follow
```

### Métriques

L'API expose des métriques de santé sur `/health` et `/api/v1/health`.

## Sécurité

- ✅ Validation des entrées avec Pydantic
- ✅ Connexion DB avec pool de connexions
- ✅ Health checks pour load balancer
- ✅ Logs structurés
- ✅ Container non-root
- ✅ CORS configuré

## Performance

- Connection pooling: 10 connexions (max 30)
- Pool recycle: 1 heure
- Health check avant utilisation connexion

## Troubleshooting

### Erreur de connexion DB

```bash
# Vérifier que PostgreSQL est accessible
psql -h $DATABASE_HOST -U $DATABASE_USER -d $DATABASE_NAME

# Vérifier les variables d'environnement
env | grep DATABASE
```

### Tests échouent

```bash
# Nettoyer la DB de test
rm test.db

# Relancer les tests
pytest -v
```

### Container ne démarre pas

```bash
# Vérifier les logs
docker logs cdnu-api

# Vérifier le health check
docker inspect cdnu-api | grep Health
```

## Contributions

1. Fork le projet
2. Créer une branche feature (`git checkout -b feature/AmazingFeature`)
3. Commit les changements (`git commit -m 'Add AmazingFeature'`)
4. Push vers la branche (`git push origin feature/AmazingFeature`)
5. Ouvrir une Pull Request

## License

MIT License - voir LICENSE pour plus de détails
