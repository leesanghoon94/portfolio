data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}
data "aws_availability_zones" "available" {}
data "aws_ecrpublic_authorization_token" "token" {
  provider = aws.virginia
  #   region = "us-east-1"
}


data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_name
}

# data "aws_eks_cluster" "endpoint" {
#   name = module.eks.cluster_endpoint
# }

# data "aws_eks_cluster" "token" { }

# data "aws_eks_cluster" "certificate_authority" {}  

# data "aws_availability_zones" "available" {
#   # Exclude local zones
#   filter {
#     name   = "opt-in-status"
#     values = ["opt-in-not-required"]
#   }
# }
