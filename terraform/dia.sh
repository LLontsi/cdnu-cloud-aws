#!/bin/bash

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔍 DIAGNOSTIC INFRASTRUCTURE CDNU - API"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# ALB State
echo ""
echo "⚖️ État de l'ALB"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
aws elbv2 describe-load-balancers \
  --query 'LoadBalancers[?contains(LoadBalancerName, `cdnu-cloud-api`)].[LoadBalancerName,State.Code,DNSName]' \
  --output table \
  --region eu-central-1

# Target Health
echo ""
echo "🎯 Santé des Targets"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
TG_ARN=$(aws elbv2 describe-target-groups \
  --query 'TargetGroups[?contains(TargetGroupName, `cdnu-cloud-api`)].TargetGroupArn' \
  --output text \
  --region eu-central-1)

if [ ! -z "$TG_ARN" ]; then
  aws elbv2 describe-target-health \
    --target-group-arn $TG_ARN \
    --region eu-central-1 \
    --output table
else
  echo "⚠️ Target Group non trouvé"
fi

# ECS Service
echo ""
echo "🐳 Service ECS"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
aws ecs describe-services \
  --cluster cdnu-cloud-cluster \
  --services cdnu-cloud-api-service \
  --region eu-central-1 \
  --query 'services[0].[serviceName,runningCount,desiredCount,deployments[0].rolloutState]' \
  --output table

# ECS Tasks
echo ""
echo "📦 Tasks ECS en cours"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
TASK_COUNT=$(aws ecs list-tasks \
  --cluster cdnu-cloud-cluster \
  --service-name cdnu-cloud-api-service \
  --region eu-central-1 \
  --query 'taskArns' \
  --output text | wc -w)

echo "Nombre de tasks: $TASK_COUNT"

if [ $TASK_COUNT -gt 0 ]; then
  TASK_ARN=$(aws ecs list-tasks \
    --cluster cdnu-cloud-cluster \
    --service-name cdnu-cloud-api-service \
    --region eu-central-1 \
    --query 'taskArns[0]' \
    --output text)
  
  echo ""
  echo "Détails de la dernière task:"
  aws ecs describe-tasks \
    --cluster cdnu-cloud-cluster \
    --tasks $TASK_ARN \
    --region eu-central-1 \
    --query 'tasks[0].[lastStatus,healthStatus,stopCode,stoppedReason]' \
    --output table
fi

# ECR Images
echo ""
echo "🐋 Images Docker dans ECR"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
IMAGE_COUNT=$(aws ecr describe-images \
  --repository-name cdnu-cloud-api \
  --region eu-central-1 \
  --query 'imageDetails' \
  --output text 2>/dev/null | wc -l)

if [ $IMAGE_COUNT -gt 0 ]; then
  echo "✅ Images trouvées: $IMAGE_COUNT"
  aws ecr describe-images \
    --repository-name cdnu-cloud-api \
    --region eu-central-1 \
    --query 'imageDetails[].[imageTags[0],imagePushedAt]' \
    --output table
else
  echo "❌ Aucune image dans ECR!"
  echo ""
  echo "🔧 Action requise: Builder et pousser l'image Docker"
  echo "   cd api/"
  echo "   docker build -t cdnu-cloud-api ."
  echo "   aws ecr get-login-password --region eu-central-1 | docker login ..."
fi

# Security Groups
echo ""
echo "🔒 Security Groups de l'ALB"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
SG_ID=$(aws elbv2 describe-load-balancers \
  --query 'LoadBalancers[?contains(LoadBalancerName, `cdnu-cloud-api`)].SecurityGroups[0]' \
  --output text \
  --region eu-central-1)

if [ ! -z "$SG_ID" ]; then
  aws ec2 describe-security-groups \
    --group-ids $SG_ID \
    --region eu-central-1 \
    --query 'SecurityGroups[0].IpPermissions[].[FromPort,ToPort,IpProtocol,IpRanges[0].CidrIp]' \
    --output table
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Diagnostic terminé!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
