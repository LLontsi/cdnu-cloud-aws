# Module Transit Gateway (G3)

## Description

Module Terraform pour créer un Transit Gateway AWS en architecture hub-and-spoke.

Le Transit Gateway sert de hub central pour interconnecter les 11 VPC des CDNU camerounais.

## Architecture

```
        Transit Gateway (Hub)
              |
    ┌─────────┼─────────┐
    │         │         │
VPC-1     VPC-2  ...  VPC-11
```

## Ressources Créées

- `aws_ec2_transit_gateway` - Transit Gateway principal
- `aws_ec2_transit_gateway_route_table` - Route table TGW

## Inputs

| Name | Description | Type | Default |
|------|-------------|------|---------|
| project_name | Nom du projet | string | - |
| environment | Environnement | string | - |

## Outputs

| Name | Description |
|------|-------------|
| id | ID du Transit Gateway |
| arn | ARN du Transit Gateway |
| route_table_id | ID de la route table |
| amazon_side_asn | ASN Amazon |

## Utilisation

```hcl
module "transit_gateway" {
  source = "./modules/transit-gateway"
  
  project_name = "cdnu-cloud"
  environment  = "production"
}
```

## Coût

**Transit Gateway** : $0.05/heure/attachment + $0.02/GB transfert
- 11 attachments × $0.05/h × 730h/mois = **~$40/mois**

## Groupe Responsable

**G3** - Architecture Haut Niveau
