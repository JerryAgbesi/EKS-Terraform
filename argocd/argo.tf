resource "helm_release" "argo_cd" {
    name       = "argo-cd"
    repository = "https://argoproj.github.io/argo-helm"
    chart      = "argo-cd"
    namespace  = "argocd"
    create_namespace = true
    version    = "7.9.0"

    values = [file("${path.module}/values/argocd.yml")]

    depends_on = [
        module.eks
    ]
  
}