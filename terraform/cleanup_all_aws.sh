#!/bin/bash

echo "🔥 DESTRUCTION ULTIME - FORCE DELETE"
echo "===================================="

REGIONS=("eu-central-1" "eu-west-3" "eu-west-1")

for REGION in "${REGIONS[@]}"; do
  echo ""
  echo "🌍 Région: $REGION"
  
  # 1. TERMINER TOUTES LES EC2
  echo "1. Terminaison EC2..."
  INSTANCES=$(aws ec2 describe-instances \
    --region $REGION \
    --filters "Name=instance-state-name,Values=running,stopped,stopping,pending" \
    --query 'Reservations[*].Instances[*].InstanceId' \
    --output text)
  
  if [ ! -z "$INSTANCES" ]; then
    aws ec2 terminate-instances --instance-ids $INSTANCES --region $REGION
    echo "  ✓ Terminé: $INSTANCES"
  fi
  
  # 2. ATTENDRE 2 MIN
  echo "2. Attente 2 min..."
  sleep 120
  
  # 3. SUPPRIMER TGW ATTACHMENTS
  echo "3. TGW Attachments..."
  ATTACHMENTS=$(aws ec2 describe-transit-gateway-attachments \
    --region $REGION \
    --query 'TransitGatewayAttachments[?State==`available`].TransitGatewayAttachmentId' \
    --output text)
  
  for attach in $ATTACHMENTS; do
    aws ec2 delete-transit-gateway-vpc-attachment \
      --transit-gateway-attachment-id $attach \
      --region $REGION 2>/dev/null && echo "  ✓ Attachment supprimé: $attach"
  done
  
  # 4. ATTENDRE 3 MIN
  echo "4. Attente 3 min..."
  sleep 180
  
  # 5. SUPPRIMER TOUS LES TGW
  echo "5. Transit Gateways..."
  TGWS=$(aws ec2 describe-transit-gateways \
    --region $REGION \
    --query 'TransitGateways[?State==`available`].TransitGatewayId' \
    --output text)
  
  for tgw in $TGWS; do
    aws ec2 delete-transit-gateway \
      --transit-gateway-id $tgw \
      --region $REGION 2>/dev/null && echo "  ✓ TGW supprimé: $tgw"
  done
  
  # 6. SUPPRIMER NAT GATEWAYS
  echo "6. NAT Gateways..."
  NATS=$(aws ec2 describe-nat-gateways \
    --region $REGION \
    --query 'NatGateways[?State==`available`].NatGatewayId' \
    --output text)
  
  for nat in $NATS; do
    aws ec2 delete-nat-gateway \
      --nat-gateway-id $nat \
      --region $REGION 2>/dev/null && echo "  ✓ NAT supprimé: $nat"
  done
  
  # 7. ATTENDRE 3 MIN
  echo "7. Attente NAT 3 min..."
  sleep 180
  
  # 8. LIBÉRER TOUTES LES EIP
  echo "8. Elastic IPs..."
  EIPS=$(aws ec2 describe-addresses \
    --region $REGION \
    --query 'Addresses[*].AllocationId' \
    --output text)
  
  for eip in $EIPS; do
    aws ec2 release-address \
      --allocation-id $eip \
      --region $REGION 2>/dev/null && echo "  ✓ EIP libéré: $eip"
  done
  
  # 9. SUPPRIMER TOUS LES VPC (sauf default)
  echo "9. VPCs..."
  VPCS=$(aws ec2 describe-vpcs \
    --region $REGION \
    --query 'Vpcs[?IsDefault==`false`].VpcId' \
    --output text)
  
  for vpc in $VPCS; do
    # IGW
    IGWS=$(aws ec2 describe-internet-gateways \
      --region $REGION \
      --filters "Name=attachment.vpc-id,Values=$vpc" \
      --query 'InternetGateways[*].InternetGatewayId' \
      --output text)
    
    for igw in $IGWS; do
      aws ec2 detach-internet-gateway --internet-gateway-id $igw --vpc-id $vpc --region $REGION 2>/dev/null
      aws ec2 delete-internet-gateway --internet-gateway-id $igw --region $REGION 2>/dev/null
    done
    
    # Subnets
    SUBNETS=$(aws ec2 describe-subnets \
      --region $REGION \
      --filters "Name=vpc-id,Values=$vpc" \
      --query 'Subnets[*].SubnetId' \
      --output text)
    
    for subnet in $SUBNETS; do
      aws ec2 delete-subnet --subnet-id $subnet --region $REGION 2>/dev/null
    done
    
    # Security Groups
    SGS=$(aws ec2 describe-security-groups \
      --region $REGION \
      --filters "Name=vpc-id,Values=$vpc" \
      --query 'SecurityGroups[?GroupName!=`default`].GroupId' \
      --output text)
    
    for sg in $SGS; do
      aws ec2 delete-security-group --group-id $sg --region $REGION 2>/dev/null
    done
    
    # VPC
    aws ec2 delete-vpc --vpc-id $vpc --region $REGION 2>/dev/null && echo "  ✓ VPC supprimé: $vpc"
  done
  
  echo "✅ Région $REGION nettoyée"
done

# 10. BUCKET S3
echo ""
echo "10. Buckets S3..."
BUCKETS=$(aws s3 ls | grep cdnu | awk '{print $3}')
for bucket in $BUCKETS; do
  aws s3 rm s3://$bucket --recursive 2>/dev/null
  aws s3 rb s3://$bucket --force 2>/dev/null && echo "  ✓ Bucket supprimé: $bucket"
done

echo ""
echo "🎉 DESTRUCTION ULTIME TERMINÉE !"