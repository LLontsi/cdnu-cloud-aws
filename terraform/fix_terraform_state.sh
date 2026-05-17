#!/bin/bash

AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
BUCKET="cdnu-terraform-state-${AWS_ACCOUNT_ID}"
STATE_KEY="production/terraform.tfstate"
TABLE_NAME="cdnu-terraform-state-lock"

echo "🔍 Diagnostic..."
echo "Bucket: $BUCKET"
echo "Key: $STATE_KEY"
echo ""

# Vérifier S3
echo "📦 Contenu S3:"
aws s3 ls s3://${BUCKET}/${STATE_KEY}
echo ""

# Vérifier DynamoDB
echo "🗄️ Entrée DynamoDB:"
aws dynamodb get-item \
    --table-name ${TABLE_NAME} \
    --key "{\"LockID\":{\"S\":\"${BUCKET}/${STATE_KEY}-md5\"}}" \
    --output json
