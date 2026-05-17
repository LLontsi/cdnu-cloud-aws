# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# MODULE: COMPUTE (G4)
# Instance EC2 par CDNU avec user-data bootstrap
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

resource "aws_instance" "main" {
  ami           = var.ami_id
  instance_type = var.instance_type

  # Network
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [var.security_group_id]
  associate_public_ip_address = true

  # IAM
  iam_instance_profile = var.iam_instance_profile

  # Storage
  root_block_device {
    volume_type           = "gp3"
    volume_size           = 20
    encrypted             = true
    delete_on_termination = true

    tags = {
      Name = "${var.cdnu_name}-root-volume"
    }
  }

  # User Data - Bootstrap script
  user_data = file("${path.module}/user-data.sh")

  # Metadata options
  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required" # IMDSv2
    http_put_response_hop_limit = 1
  }

  # Monitoring
  monitoring = true

  tags = {
    Name        = "${var.cdnu_name}-ec2"
    CDNU        = var.cdnu_name
    Environment = "production"
    Backup      = "daily"
  }

  lifecycle {
    ignore_changes = [ami]
  }
}

# Elastic IP (optionnel, pour IP statique)

