module "iam_assumable_role_alb_controller" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "5.0.0"
  create_role                   = true
  role_name                     = "${local.name}-alb-controller" #"${local.cluster_name}-alb-controller" 
  role_description              = "Used by AWS Load Balancer Controller for EKS"
  provider_url                  = module.eks.cluster_oidc_issuer_url
  oidc_fully_qualified_subjects = ["system:serviceaccount:kube-system:aws-load-balancer-controller"]
}


data "http" "iam_policy" {
  url = "https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v3.3.0/docs/install/iam_policy.json"
}

# 인라인으로 정책 추가
resource "aws_iam_role_policy" "controller" {
  name_prefix = "AWSLoadBalancerControllerIAMPolicy"
  policy      = data.http.iam_policy.response_body
  role        = module.iam_assumable_role_alb_controller.iam_role_name
}

# module "vpc_cni_irsa" {
#   source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts"

#   name   = "vpc-cni"

#   attach_vpc_cni_policy = true
#   vpc_cni_enable_ipv4   = true

#   oidc_providers = {
#     this = {
#       provider_arn               = "arn:aws:iam::012345678901:oidc-provider/oidc.eks.us-east-1.amazonaws.com/id/5C54DDF35ER19312844C7333374CC09D"
#       namespace_service_accounts = ["kube-system:aws-node"]
#     }
#   }

#   tags = {
#     Terraform   = "true"
#     Environment = "dev"
#   }
# }
