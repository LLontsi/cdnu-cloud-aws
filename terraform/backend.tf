# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Backend S3 pour Terraform State
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

terraform {
  backend "s3" {
    # TODO: Remplacer VOTRE-ACCOUNT-ID par votre ID de compte AWS
    # Obtenir avec: aws sts get-caller-identity --query Account --output text
    bucket = "cdnu-terraform-state-1587096406"

    key    = "production/terraform.tfstate"
    region = "eu-central-1"

    # Encryption du state
    encrypt = true

    # Table DynamoDB pour le verrouillage
    dynamodb_table = "cdnu-terraform-locks"

    # Tags du bucket
    # (appliqués lors de la création du bucket S3)
  }
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# INSTRUCTIONS DE CONFIGURATION
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#
# 1. Créer le bucket S3:
#    export AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
#    aws s3 mb s3://cdnu-terraform-state-$AWS_ACCOUNT_ID --region eu-central-1
#
# 2. Activer le versioning:
#    aws s3api put-bucket-versioning \
#      --bucket cdnu-terraform-state-$AWS_ACCOUNT_ID \
#      --versioning-configuration Status=Enabled
#
# 3. Créer la table DynamoDB pour locks:
#    aws dynamodb create-table \
#      --table-name cdnu-terraform-locks \
#      --attribute-definitions AttributeName=LockID,AttributeType=S \
#      --key-schema AttributeName=LockID,KeyType=HASH \
#      --billing-mode PAY_PER_REQUEST \
#      --region eu-central-1
#
# 4. Remplacer VOTRE-ACCOUNT-ID dans ce fichier
#
# 5. Initialiser Terraform:
#    terraform init
#
