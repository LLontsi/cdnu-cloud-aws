# Module Compute (G4)

## Description

Module Terraform pour déployer une instance EC2 par CDNU avec :
- Bootstrap automatique via user-data
- CloudWatch Agent pour monitoring
- Docker pré-installé
- Sécurité renforcée (IMDSv2, fail2ban)

## Architecture

```
EC2 Instance (t3.micro)
├── Amazon Linux 2
├── Docker
├── CloudWatch Agent
├── PostgreSQL Client
└── Python 3.9+
```

## Ressources Créées

- `aws_instance` - Instance EC2
- `aws_eip` - Elastic IP (IP statique)

## User Data Bootstrap

Le script `user-data.sh` installe :
1. Packages système (git, docker, postgresql)
2. CloudWatch Agent (metrics + logs)
3. Sécurité (fail2ban, SSH hardening)
4. Python 3.9+ avec boto3

## Inputs

| Name | Description | Type | Required |
|------|-------------|------|----------|
| cdnu_name | Nom du CDNU | string | yes |
| instance_type | Type EC2 | string | yes |
| ami_id | AMI Amazon Linux 2 | string | yes |
| subnet_id | ID subnet | string | yes |
| security_group_id | ID SG | string | yes |
| iam_instance_profile | IAM profile | string | yes |

## Outputs

| Name | Description |
|------|-------------|
| instance_id | ID instance EC2 |
| public_ip | IP publique (EIP) |
| private_ip | IP privée |

## Utilisation

```hcl
module "compute" {
  source   = "./modules/compute"
  for_each = var.cdnu_configs
  
  cdnu_name             = each.key
  instance_type         = each.value.instance_type
  ami_id                = data.aws_ami.amazon_linux_2.id
  subnet_id             = module.vpc[each.key].public_subnet_id
  security_group_id     = module.vpc[each.key].compute_security_group_id
  iam_instance_profile  = module.iam.ec2_instance_profile_name
}
```

## Connexion SSH

```bash
# Récupérer l'IP publique
terraform output ec2_public_ips

# Se connecter
ssh -i ~/.ssh/cdnu-key.pem ec2-user@<PUBLIC_IP>
```

## Logs

```bash
# Logs user-data
sudo cat /var/log/user-data.log

# Logs CloudWatch
aws logs tail /aws/ec2/cdnu --follow
```

## Coût

- Instance t3.micro : **Gratuit** (Free Tier 12 mois, 750h/mois)
- EIP : Gratuit si attaché à instance running
- CloudWatch : ~$2/mois (metrics + logs)

## Groupe Responsable

**G4** - Infrastructure as Code (Réseau + Compute)
