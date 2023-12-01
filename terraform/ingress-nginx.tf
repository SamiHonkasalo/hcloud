resource "helm_release" "ingress-nginx" {
  depends_on       = [local_sensitive_file.kubeconfig]
  name             = "ingress-nginx"
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  version          = "4.8.0"
  namespace        = "ingress-nginx"
  create_namespace = true
  set {
    name = "controller.config.proxy-buffer-size"
    value = "16k"
  }
}
