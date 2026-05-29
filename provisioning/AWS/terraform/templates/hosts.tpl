all:
  children:
    backend:
      hosts:
        aws-backend:
          ansible_host: ${instance_ip}
          ansible_user: ubuntu
          ansible_ssh_private_key_file: ~/.ssh/devops-aws.pem