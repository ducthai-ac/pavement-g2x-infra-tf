output "instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.app_server.id
}

output "public_ip" {
  description = "EC2 instance public IP"
  value       = aws_instance.app_server.public_ip
}

output "elastic_ip" {
  description = "Elastic IP address"
  value       = aws_eip.app_eip.public_ip
}

output "private_ip" {
  description = "EC2 instance private IP"
  value       = aws_instance.app_server.private_ip
}

output "security_group_id" {
  description = "Security group ID"
  value       = aws_security_group.app_sg.id
}