resource "helm_release" "metrics-server" {
	name       = "metrics-server"
	repository = "https://kubernetes-sigs.github.io/metrics-server/"
	chart      = "metrics-server"
	namespace = "kube-system"
	version    = "3.12.2"

	values = [file("${path.module}/values/metrics-server.yml")]

	depends_on = [
			module.eks
	]  
}