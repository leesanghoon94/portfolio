# resource "helm_release" "prometheus" {
#   namespace        = "prometheus"
#   create_namespace = true

#   name       = "prometheus"
#   repository = "https://prometheus-community.github.io/helm-charts"
#   chart      = "prometheus"
#   version    = "29.6.0"

#   set = [
#     {
#       name  = "alertmanager.persistence.storageClass"
#       value = "gp2"
#     },
#     {
#       name  = "server.persistentVolume.storageClass"
#       value = "gp2"
#     }
#   ]
# }
