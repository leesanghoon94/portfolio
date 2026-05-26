Requirements¶  
Installed kubectl command-line tool.
Have a kubeconfig file (default location is ~/.kube/config).
CoreDNS. Can be enabled for microk8s by microk8s enable dns && microk8s stop && microk8s start

1. Install Argo CD¶

kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

3. Access The Argo CD API Server¶
   By default, the Argo CD API server is not exposed with an external IP. To access the API server, choose one of the following techniques to expose the Argo CD API server:

Service Type Load Balancer¶
Change the argocd-server service type to LoadBalancer:

kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'

4. Login Using The CLI¶
   The initial password for the admin account is auto-generated and stored as clear text in the field password in a secret named argocd-initial-admin-secret in your Argo CD installation namespace. You can simply retrieve this password using the argocd CLI:

argocd admin initial-password -n argocd
k -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
Warning

You should delete the argocd-initial-admin-secret from the Argo CD namespace once you changed the password. The secret serves no other purpose than to store the initially generated password in clear and can safely be deleted at any time. It will be re-created on demand by Argo CD if a new admin password must be re-generated.

### 출처

- https://argo-cd.readthedocs.io/en/stable/getting_started/#service-type-load-balancer

---

k create ns argocd
helm repo add argo https://argoproj.github.io/argo-helm
helm fetch argo/argo-cd
helm install argocd argo/argo-cd --namespace argocd
curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
sudo install -m 555 argocd-linux-amd64 /usr/local/bin/argocd
rm argocd-linux-amd64

argocd cluster add kubernetes-admin@kubernetes
