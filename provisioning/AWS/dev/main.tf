provider "aws" {
  region = var.region
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "backend-server" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type

  vpc_security_group_ids = [module.security-group-backend.security_group_id]
  subnet_id              = module.default-vpc.public_subnets[0]
  key_name               = var.key_pair_name

  tags = {
    Name = var.instance_name
  }
}


module "default-vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~>5.19.0"

  name = "default-vps"
  cidr = "10.0.0.0/16"

  azs             = var.zones
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24"]
  
  map_public_ip_on_launch = true
  enable_dns_hostnames = true
}

module "security-group-backend" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~>4.5.0"
  
  name = "backend"
  vpc_id = module.default-vpc.vpc_id

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules = ["http-80-tcp", "https-443-tcp", "ssh-tcp"]
}
