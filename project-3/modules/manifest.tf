resource "helm_release" "lb-controller" {
  namespace = "kube-system"
  name      = "aws-load-balancer-controller"

  repository          = "https://aws.github.io/eks-charts"
  chart               = "aws-load-balancer-controller"
  repository_password = data.aws_ecrpublic_authorization_token.token.password
  repository_username = data.aws_ecrpublic_authorization_token.token.user_name

  version = "3.4.1"
  set = [
    {
      name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
      value = module.iam_assumable_role_alb_controller.iam_role_arn
    },
    {
      name  = "vpcId"
      value = var.vpc_id
    },
    {
      name  = "clusterName"
      value = module.eks.cluster_name
    },
    {
      name  = "serviceAccount.name"
      value = "aws-load-balancer-controller"
    }
  ]
  depends_on = [
    module.eks,
    helm_release.cert-manager
  ]

}

resource "helm_release" "cert-manager" {
  create_namespace    = true
  namespace           = "cert-manager"
  name                = "cert-manager"
  repository          = "https://charts.jetstack.io"
  chart               = "cert-manager"
  repository_password = data.aws_ecrpublic_authorization_token.token.password
  repository_username = data.aws_ecrpublic_authorization_token.token.user_name
  version             = "v1.21.0"
  set = [
    {
      name  = "crds.enabled"
      value = "true"
    },
  ]
}

# resource "helm_release" "metircs-server" {
#   name       = "metrics-server"
#   repository = "https://kubernetes-sigs.github.io/metrics-server/"
#   chart      = "metrics-server"
#   namespace  = "kube-system"
#   version    = "3.13.1"

#   depends_on = [
#     module.eks,
#     helm_release.lb-controller
#   ]
# }
