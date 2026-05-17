#!/bin/bash
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# USER DATA - Bootstrap EC2 CDNU
# Script exécuté au démarrage de l'instance
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

set -e

# Logging
exec > >(tee /var/log/user-data.log)
exec 2>&1

echo "========================================="
echo "BOOTSTRAP EC2 CDNU - $(date)"
echo "========================================="

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# MISE À JOUR SYSTÈME
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

echo "[1/6] Mise à jour système..."
yum update -y

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# INSTALLATION PACKAGES DE BASE
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

echo "[2/6] Installation packages..."
yum install -y \
  git \
  wget \
  curl \
  vim \
  htop \
  ntp \
  jq \
  awscli \
  postgresql15 \
  docker

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# CONFIGURATION DOCKER
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

echo "[3/6] Configuration Docker..."
systemctl enable docker
systemctl start docker

# Ajouter ec2-user au groupe docker
usermod -a -G docker ec2-user

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# INSTALLATION CLOUDWATCH AGENT
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

echo "[4/6] Installation CloudWatch Agent..."
wget https://s3.amazonaws.com/amazoncloudwatch-agent/amazon_linux/amd64/latest/amazon-cloudwatch-agent.rpm
rpm -U ./amazon-cloudwatch-agent.rpm
rm -f ./amazon-cloudwatch-agent.rpm

# Configuration CloudWatch Agent
cat > /opt/aws/amazon-cloudwatch-agent/etc/config.json << 'EOF'
{
  "metrics": {
    "namespace": "CDNU/EC2",
    "metrics_collected": {
      "cpu": {
        "measurement": [{"name": "cpu_usage_idle", "rename": "CPU_IDLE", "unit": "Percent"}],
        "totalcpu": false
      },
      "disk": {
        "measurement": [{"name": "used_percent", "rename": "DISK_USED", "unit": "Percent"}],
        "resources": ["*"]
      },
      "mem": {
        "measurement": [{"name": "mem_used_percent", "rename": "MEM_USED", "unit": "Percent"}]
      }
    }
  },
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          {
            "file_path": "/var/log/messages",
            "log_group_name": "/aws/ec2/cdnu",
            "log_stream_name": "{instance_id}/messages"
          }
        ]
      }
    }
  }
}
EOF

/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
  -a fetch-config \
  -m ec2 \
  -s \
  -c file:/opt/aws/amazon-cloudwatch-agent/etc/config.json

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# CONFIGURATION SÉCURITÉ
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

echo "[5/6] Configuration sécurité..."

# Désactiver root login SSH
sed -i 's/PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config

# Configuration fail2ban
yum install -y fail2ban
systemctl enable fail2ban
systemctl start fail2ban

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# INSTALLATION PYTHON 3.9+
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

echo "[6/6] Installation Python..."
yum install -y python3 python3-pip
pip3 install --upgrade pip

# Installer packages Python utiles
pip3 install \
  boto3 \
  psycopg2-binary \
  requests

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# CRÉATION FICHIER INFO INSTANCE
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# Récupérer metadata instance
INSTANCE_ID=$(ec2-metadata --instance-id | cut -d " " -f 2)
AVAILABILITY_ZONE=$(ec2-metadata --availability-zone | cut -d " " -f 2)
PUBLIC_IP=$(ec2-metadata --public-ipv4 | cut -d " " -f 2)
PRIVATE_IP=$(ec2-metadata --local-ipv4 | cut -d " " -f 2)

cat > /home/ec2-user/instance-info.txt << EOF
CDNU EC2 Instance Information
=============================
Instance ID: $INSTANCE_ID
Availability Zone: $AVAILABILITY_ZONE
Public IP: $PUBLIC_IP
Private IP: $PRIVATE_IP
Bootstrap Date: $(date)
EOF

chown ec2-user:ec2-user /home/ec2-user/instance-info.txt

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# MESSAGE DE BIENVENUE
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

cat > /etc/motd << 'EOF'
╔════════════════════════════════════════════╗
║                                            ║
║     🏛️  CDNU CLOUD AWS - EC2 INSTANCE      ║
║                                            ║
║  Projet: Infrastructure 11 CDNU            ║
║  Année: 2026                               ║
║  Institution: Université de Yaoundé I      ║
║                                            ║
╚════════════════════════════════════════════╝

Type 'cat ~/instance-info.txt' pour voir les infos instance

EOF

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# FIN
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

echo "========================================="
echo "BOOTSTRAP TERMINÉ - $(date)"
echo "========================================="
