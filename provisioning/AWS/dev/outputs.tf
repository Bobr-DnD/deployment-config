output "instance_hostname" {
  description = "Private DNS name of the EC2 instance."
  value       = aws_instance.backend-server.private_dns
}

output "public_ip" {
  description = "Public instance ip"
  value = aws_instance.backend-server.public_ip
}