#Note to self: this creates an nlb, you should comment it out if you will not be using it
resource "helm_release" "nginx-ingress" {
  name       = "nginx-ingress"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  namespace  = "ingress-nginx"
  create_namespace = true
  version    = "4.12.1"

  values = [file("${path.module}/values/nginx-ingress.yml")]

  depends_on = [
    module.eks
  ]
  
}