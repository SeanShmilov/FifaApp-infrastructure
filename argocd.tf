resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = "argocd"
  create_namespace = true
  version          = "5.51.6"

  # We set server.service.type to NodePort or LoadBalancer so we can access the UI,
  # but for EKS, ClusterIP is fine if we use port-forwarding, or LoadBalancer if we want an ELB.
  # Since this is a test environment on t3.micro, let's keep it minimal and use ClusterIP, 
  # and we'll port-forward to access the UI.
  set {
    name  = "server.service.type"
    value = "ClusterIP"
  }

  depends_on = [module.eks]
}
