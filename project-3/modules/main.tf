provider "aws" {
  region = local.region
}

locals {
  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version
  region          = "ap-northeast-2"
  vpc_id          = var.vpc_id
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
  name     = basename(path.cwd)
  vpc_cidr = "10.0.0.0/16"
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)

  private_subnet_map = {
    a = var.private_subnets[0]
    b = var.private_subnets[1]
  }
  public_subnet_map = {
    a = var.public_subnets[0]
    b = var.public_subnets[1]
  }

}


##################################
########eks
#############################
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"
  name    = local.name

  kubernetes_version = "1.33"
  compute_config = {
    enabled = false
  }

  control_plane_scaling_config = {
    tier = "standard"
  }

  addons = {
    coredns = {}
    eks-pod-identity-agent = {
      before_compute = true
    }
    kube-proxy = {}
    vpc-cni = {
      before_compute = true
    }
    metrics-server = {}
  }

  endpoint_public_access = true
  # Optional: Adds the current caller identity as an administrator via cluster access entry
  enable_cluster_creator_admin_permissions = true

  vpc_id     = var.vpc_id
  subnet_ids = var.private_subnets
  # control_plane_subnet_ids = module.vpc.intra_subnets

  eks_managed_node_groups = {
    initial = {
      # ami_type       = "AL2023_x86_64_STANDARD"
      instance_types = ["t3.medium"]
      min_size       = 1
      max_size       = 100
      desired_size   = 1


      labels = {
        "karpenter.sh/controller" = "true"
      }
    }

  }
  node_security_group_tags = merge(local.tags, {
    # NOTE - if creating multiple security groups with this module, only tag the
    # security group that Karpenter should utilize with the following tag
    # (i.e. - at most, only one security group should have this tag in your account)
    "karpenter.sh/discovery" = local.name
  })
  tags = local.tags

}








##############################

# module "eks" {
#   # https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/latest
#   source  = "terraform-aws-modules/eks/aws"
#   version = "20.8.4"

#   # Cluster Name Setting
#   cluster_name    = local.cluster_name
#   cluster_version = local.cluster_version

#   # Cluster Endpoint Setting
#   cluster_endpoint_private_access = true
#   cluster_endpoint_public_access  = true

#   # Network Setting
#   vpc_id     = local.vpc_id
#   subnet_ids = local.private_subnets

#   # IRSA Enable / OIDC 구성
#   enable_irsa = true

#   node_security_group_additional_rules = {
#     ingress_nodes_karpenter_port = {
#       description                   = "Cluster API to Node group for Karpenter webhook"
#       protocol                      = "tcp"
#       from_port                     = 8443
#       to_port                       = 8443
#       type                          = "ingress"
#       source_cluster_security_group = true
#     }
#   }

#   # Tag Node Security Group
#   node_security_group_tags = {
#     "karpenter.sh/discovery" = local.cluster_name
#   }

#   eks_managed_node_groups = {
#     initial = {
#       instance_types         = ["t3.large"]
#       create_security_group  = false
#       create_launch_template = false # do not remove
#       launch_template_name   = ""    # do not remove

#       min_size     = 2
#       max_size     = 3
#       desired_size = 2

#       iam_role_additional_policies = [
#         # Required by Karpenter
#         "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
#       ]
#     }
#   }

#   # console identity mapping (AWS user)
#   # eks configmap aws-auth에 콘솔 사용자 혹은 역할을 등록
#   manage_aws_auth_configmap = true

#   aws_auth_users = [
#     {
#       userarn  = "arn:aws:iam::992382792232:user/admin"
#       username = "admin"
#       groups   = ["system:masters"]
#     },
#     {
#       userarn  = "arn:aws:iam::992382792232:root"
#       username = "root"
#       groups   = ["system:masters"]
#     }
#   ]

#   aws_auth_accounts = [
#     "992382792232"
#   ]
# }

// 프라이빗 서브넷 태그
# resource "aws_ec2_tag" "private_subnet_tag" {
#   # for_each    = toset(local.private_subnets)
#   # resource_id = each.value
#   key         = "kubernetes.io/role/internal-elb"
#   value       = "1"
#   count       = length(var.private_subnets)
#   resource_id = var.private_subnets[count.index]
# }

# resource "aws_ec2_tag" "private_subnet_cluster_tag" {
#   # for_each    = toset(local.private_subnets)
#   # resource_id = each.value
#   count       = length(var.private_subnets)
#   resource_id = var.private_subnets[count.index]
#   key         = "kubernetes.io/cluster/${local.cluster_name}"
#   value       = "owned"
# }

# resource "aws_ec2_tag" "private_subnet_karpenter_tag" {
#   # for_each    = toset(local.private_subnets)
#   # resource_id = each.value
#   count       = length(var.private_subnets)
#   resource_id = var.private_subnets[count.index]
#   key         = "karpenter.sh/discovery/${local.cluster_name}"
#   value       = local.cluster_name
# }

# // 퍼블릭 서브넷 태그
# resource "aws_ec2_tag" "public_subnet_tag" {
#   # for_each    = toset(local.public_subnets)
#   # resource_id = each.value
#   count       = length(var.public_subnets)
#   resource_id = var.public_subnets[count.index]
#   key         = "kubernetes.io/role/elb"
#   value       = "1"
# }


