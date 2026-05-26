# module "karpenter" {
#   source       = "terraform-aws-modules/eks/aws//modules/karpenter"
#   version      = "20.17.2"
#   cluster_name = module.eks.cluster_name

#   create_node_iam_role = false
#   create_access_entry  = false

#   namespace = "karpenter"

#   create_instance_profile = true

#   enable_pod_identity             = true
#   create_pod_identity_association = true
#   enable_irsa                     = true

#   irsa_oidc_provider_arn = module.eks.oidc_provider_arn

#   node_iam_role_arn = module.eks.eks_managed_node_groups["karpenter"].iam_role_arn

#   # Used to attach additional IAM policies to the Karpenter node IAM role 
#   node_iam_role_additional_policies = {
#     AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
#   }
# }

# resource "helm_release" "karpenter" {
#   namespace           = "karpenter"
#   create_namespace    = true
#   name                = "karpenter"
#   repository          = "oci://public.ecr.aws/karpenter"
#   repository_username = data.aws_ecrpublic_authorization_token.token.user_name
#   repository_password = data.aws_ecrpublic_authorization_token.token.password
#   chart               = "karpenter"
#   version             = "0.37.0"

#   set {
#     name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
#     value = module.karpenter.iam_role_arn
#   }
#   set {
#     name  = "settings.clusterName"
#     value = module.eks.cluster_name
#   }

#   set {
#     name  = "settings.interruptionQueueName"
#     value = module.karpenter.queue_name
#   }

# }
