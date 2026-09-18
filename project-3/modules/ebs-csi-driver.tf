module "ebs-csi-driver" {
  source  = "DrFaust92/ebs-csi-driver/kubernetes"
  version = "3.10.0"
  oidc_url= module.eks.oidc_provider
}