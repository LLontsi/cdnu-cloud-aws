# Architecture Réseau

## Plan d'Adressage
Chaque CDNU dispose d'un VPC /16:
- Yaoundé: 10.0.0.0/16
- Douala: 10.1.0.0/16
- (etc.)

## Transit Gateway
Hub-and-spoke architecture avec 3 TGW (1 par région).

## Security Groups
- SG-Compute: SSH, HTTP, HTTPS
- SG-Database: PostgreSQL depuis SG-Compute/SG-ECS
- SG-ALB: HTTP/HTTPS public
- SG-ECS: Port 8000 depuis SG-ALB

Voir documentation complète dans les PDFs LaTeX.
