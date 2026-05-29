output "instance_hostname" {
  description = "Private DNS name of the EC2 instance."
  value       = aws_instance.backend-server.private_dns
}

output "public_ip" {
  description = "Public instance ip"
  value       = aws_instance.backend-server.public_ip
}

output "public_dns" {
  description = "FQDN"
  value       = aws_instance.backend-server.public_dns
}

resource "local_file" "ansible_inventory" {
  content = templatefile("templates/hosts.tpl", {
    instance_ip = aws_instance.backend-server.public_ip
  })
  filename = "../ansible/inventory/hosts.yml"
}