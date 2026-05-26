provider "aws" {
  region = local.region
}
data "aws_availability_zones" "available" {
  # Exclude local zones
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}
data "aws_ecrpublic_authorization_token" "token" {
  region = "us-east-1"
}

locals {
  name   = basename(path.cwd)
  region = "ap-northeast-2"

  vpc_cidr = "10.0.0.0/16"
  azc      = slice(data.aws_availability_zones.available.names, 0, 3)
}
module "eks" {
  source       = "./modules"
  cluster_name = var.cluster_name
  vpc_id       = module.vpc.vpc_id

  private_subnets = module.vpc.private_subnets
  public_subnets  = module.vpc.public_subnets


}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 6.0"

  name = "my-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["ap-northeast-2a", "ap-northeast-2c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

  enable_nat_gateway      = true
  single_nat_gateway      = true
  one_nat_gateway_per_az  = false
  map_public_ip_on_launch = true

  public_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}"  = "shared"
    "kubernetes.io/role/elb"                     = 1
    "karpenter.sh/discovery"                     = var.cluster_name
    "karpenter.sh/discovery/${var.cluster_name}" = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
  }

  tags = {
    "kubernetes.io/cluster/${var.cluster_name}"  = "shared"
    "karpenter.sh/discovery/${var.cluster_name}" = "1"

  }
}


#NOTE:
#The usage of the specific kubernetes.io/cluster/* , "shared"
#resource tags below are required for EKS and Kubernetes to discover and manage networking resources.
