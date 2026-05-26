locals {
  cluster_name    = var.cluster_name
  vpc_id          = var.vpc_id
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets
  region          = "ap-northeast-2"
}
provider "aws" {
  region = "us-east-1"
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.17.2"

  cluster_name    = local.cluster_name
  cluster_version = "1.30"
  # cluster endpoint 
  cluster_endpoint_public_access = true
  # cluster_endpoint_private_access = true

  # cloudwatch log group
  create_cloudwatch_log_group = false
  # irsa enable / OIDC 구성 enable_irsa = true defualt true
  # create iam role defualt true
  cluster_addons = {
    coredns                = {}
    eks-pod-identity-agent = {}
    kube-proxy             = {}
    vpc-cni                = {}
  }

  # vpc_id     = var.vpc_id
  # subnet_ids = var.public_subnets
  #control_plane_subnet_ids = ["subnet-xyzde987", "subnet-slkjf456", "subnet-qeiru789"]

  # EKS Managed Node Group(s)
  # eks_managed_node_group_defaults = {
  #   #instance_types = ["m6i.large", "m5.large", "m5n.large", "m5zn.large"]
  #   ami_type = "AL2023_x86_64_STANDARD"
  # }

  eks_managed_node_groups = {
    karpenter = {
      # Starting on 1.30, AL2023 is the default AMI type for EKS managed node groups
      ami_type       = "AL2023_x86_64_STANDARD"
      instance_types = ["t3.large"]
      min_size       = 1
      max_size       = 3
      desired_size   = 2

      taints = {
        #     # This Taint aims to keep just EKS Addons and Karpenter running on this MNG
        #     # The pods that do not tolerate this taint should run on nodes created by Karpenter
        addons = {
          key   = "CriticalAddonsOnly"
          value = "true"
        effect = "NO_SCHEDULE" }
      },
    }
  }

  # tag node security group
  node_security_group_tags = {
    "karpenter.sh/discovery" = local.cluster_name
  }

  # Cluster access entry
  # To add the current caller identity as an administrator
  enable_cluster_creator_admin_permissions = true

  access_entries = {
    # One access entry with a policy associated
    root = {
      kubernetes_groups = []
      principal_arn     = "arn:aws:iam::992382792232:root"

      policy_associations = {
        root = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            type = "cluster"
          }
        }
      }
    }

    # example = {
    #   kubernetes_groups = []
    #   principal_arn     = "arn:aws:iam::992382792232:role/something"

    #   policy_associations = {
    #     example = {
    #       policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSViewPolicy"
    #       access_scope = {
    #         type = "cluster"
    #         # namespaces = ["default"]
    #         # type       = "namespace"
    #       }
    #     }
    #   }
    # }
  }

  tags = {
    "kubernetes.io/cluster/${var.cluster_name}"  = "shared"
    "karpenter.sh/discovery/${var.cluster_name}" = "1"
    Terraform                                    = "true"
    # "kubernetes.io/cluster/${var.cluster_name}"  = "shared"
    # "karpenter.sh/discovery/${var.cluster_name}" = "1"
    "karpenter.sh/discovery"  = local.cluster_name
    "karpenter.sh/controller" = "true"

  }
}

module "aws-auth" {
  source  = "terraform-aws-modules/eks/aws//modules/aws-auth"
  version = "~> 20.0"

  manage_aws_auth_configmap = true

  aws_auth_roles = [
    {
      rolearn  = module.eks.karpenter.node_iam_role_arn
      username = "system:node:{{EC2PrivateDNSName}}"
      groups   = ["system:bootstrappers", "system:nodes"]
    },
  ]
}
// 프라이빗 서브넷 태그
resource "aws_ec2_tag" "private_subnet_tag" {
  for_each    = toset(local.private_subnets)
  resource_id = each.value
  key         = "kubernetes.io/role/internal-elb"
  value       = "1"
}
# 
resource "aws_ec2_tag" "private_subnet_cluster_tag" {
  for_each    = toset(local.private_subnets)
  resource_id = each.value
  key         = "kubernetes.io/cluster/${local.cluster_name}"
  value       = "owned"
}

resource "aws_ec2_tag" "private_subnet_karpenter_tag" {
  for_each    = toset(local.private_subnets)
  resource_id = each.value
  key         = "karpenter.sh/discovery/${local.cluster_name}"
  value       = local.cluster_name
}

// 퍼블릭 서브넷 태그
resource "aws_ec2_tag" "public_subnet_tag" {
  for_each = toset(local.public_subnets)
  # for_each    = toset(var.public_subnets)
  resource_id = each.value
  key         = "kubernetes.io/role/elb"
  value       = "1"
}
