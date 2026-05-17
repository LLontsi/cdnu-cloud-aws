# Prérequis

## Outils Nécessaires

### Terraform
```bash
# Installation
wget https://releases.hashicorp.com/terraform/1.7.0/terraform_1.7.0_linux_amd64.zip
unzip terraform_1.7.0_linux_amd64.zip
sudo mv terraform /usr/local/bin/

# Vérification
terraform version
```

### AWS CLI
```bash
# Installation
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# Vérification
aws --version
```

### Docker
```bash
# Installation
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Vérification
docker --version
```

### Python 3.11+
```bash
# Installation
sudo apt install python3.11 python3-pip

# Vérification
python3 --version
```

## Comptes Requis
- Compte AWS avec droits admin
- Compte GitHub
- Budget: ~$500/mois
