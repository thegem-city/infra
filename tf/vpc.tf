variable "vpc_cidr" {
  default = "10.10.0.0/16"
}

locals {
  vpc_subnets_dc_external = [cidrsubnet(var.vpc_cidr, 8, 1), cidrsubnet(var.vpc_cidr, 8, 2), cidrsubnet(var.vpc_cidr, 8, 3)]
  vpc_subnets_dc_apps     = [cidrsubnet(var.vpc_cidr, 8, 4), cidrsubnet(var.vpc_cidr, 8, 5), cidrsubnet(var.vpc_cidr, 8, 6)]
  # vpc_subnets_rds         = [cidrsubnet(var.vpc_cidr, 8, 4), cidrsubnet(var.vpc_cidr, 8, 5), cidrsubnet(var.vpc_cidr, 8, 6)]
}

output "vpc_subnets" {
  value = {
    dc_cidr : var.vpc_cidr,
    dc_external : local.vpc_subnets_dc_external,
    dc_apps : local.vpc_subnets_dc_apps,
  }
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.18.1"


  name = "the-gem-city-vpc"
  cidr = var.vpc_cidr
  azs  = ["us-east-2a", "us-east-2b", "us-east-2c"]

  public_subnets  = local.vpc_subnets_dc_external
  private_subnets = local.vpc_subnets_dc_apps

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  create_database_subnet_group = false
}

resource "aws_security_group" "default" {
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
