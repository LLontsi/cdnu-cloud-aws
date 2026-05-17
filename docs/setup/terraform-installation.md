# Installation Terraform

## Linux
```bash
wget https://releases.hashicorp.com/terraform/1.7.0/terraform_1.7.0_linux_amd64.zip
unzip terraform_1.7.0_linux_amd64.zip
sudo mv terraform /usr/local/bin/
```

## macOS
```bash
brew tap hashicorp/tap
brew install hashicorp/tap/terraform
```

## Windows
1. Télécharger depuis hashicorp.com
2. Extraire dans C:\terraform
3. Ajouter au PATH

## Vérification
```bash
terraform version
# Terraform v1.7.0
```

## Initialisation
```bash
cd terraform
terraform init
```
