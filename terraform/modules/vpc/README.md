# Module VPC (G4)

## Description

Module Terraform pour créer un VPC complet par CDNU avec :
- Subnets public et privés
- Internet Gateway
- NAT Gateway
- Route Tables
- Security Groups
- Attachment Transit Gateway

## Architecture

```
VPC (10.x.0.0/16)
│
├── Subnet Public (10.x.1.0/24)
│   ├── Internet Gateway
│   └── EC2 instances avec IP publiques
│
├── Subnets Privés (10.x.10.0/24, 10.x.11.0/24)
│   ├── NAT Gateway (pour Internet sortant)
│   ├── RDS PostgreSQL (Multi-AZ)
│   └── Resources internes
│
└── Transit Gateway Attachment
    └── Communication inter-VPC
```

## Ressources Créées

- `aws_vpc` - VPC principal
- `aws_subnet` - 3 subnets (1 public, 2 privés)
- `aws_internet_gateway` - Accès Internet
- `aws_nat_gateway` - NAT pour subnets privés
- `aws_eip` - Elastic IP pour NAT
- `aws_route_table` - Tables de routage
- `aws_security_group` - 3 SG (compute, database, api)
- `aws_ec2_transit_gateway_vpc_attachment` - Attachment TGW

## Inputs

| Name | Description | Type | Required |
|------|-------------|------|----------|
| cdnu_name | Nom du CDNU | string | yes |
| vpc_cidr | CIDR VPC | string | yes |
| availability_zone | AZ | string | yes |
| transit_gateway_id | ID TGW | string | yes |

## Outputs

| Name | Description |
|------|-------------|
| vpc_id | ID du VPC |
| public_subnet_id | ID subnet public |
| private_subnet_ids | IDs subnets privés |
| compute_security_group_id | SG EC2 |
| database_security_group_id | SG RDS |

## Utilisation

```hcl
module "vpc" {
  source   = "./modules/vpc"
  for_each = var.cdnu_configs
  
  cdnu_name          = each.key
  vpc_cidr           = each.value.vpc_cidr
  availability_zone  = each.value.az
  transit_gateway_id = module.transit_gateway.id
}
```

## Coût

**Par VPC** :
- NAT Gateway : $0.045/h = ~$32/mois
- Elastic IP : Gratuit si attaché
- Transit Gateway attachment : $0.05/h = ~$36/mois

**Total par VPC** : ~$70/mois

## Groupe Responsable

**G4** - Infrastructure as Code (Réseau)
