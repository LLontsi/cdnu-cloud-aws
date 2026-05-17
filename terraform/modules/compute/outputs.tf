output "instance_id" {
  description = "ID de l'instance EC2"
  value       = aws_instance.main.id
}

output "public_ip" {
  description = "Adresse IP publique"
  value       = aws_instance.main.public_ip
}

output "private_ip" {
  description = "Adresse IP privée"
  value       = aws_instance.main.private_ip
}

output "arn" {
  description = "ARN de l'instance"
  value       = aws_instance.main.arn
}

output "availability_zone" {
  description = "Availability Zone"
  value       = aws_instance.main.availability_zone
}
