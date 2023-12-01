resource "helm_release" "cert_manager" {
  depends_on       = [helm_release.ingress-nginx]
  name             = "cert-manager"
  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"
  version          = "v1.13.2"
  namespace        = "cert-manager"
  create_namespace = true
  set {
    name  = "installCRDs"
    value = "true"
  }
}

resource "kubectl_manifest" "cluster_issuers" {
  depends_on = [helm_release.cert_manager]
  lifecycle {
    replace_triggered_by = [
      filesha1("${path.module}/cluster-issuers.yaml")
    ]
  }
  yaml_body = file("${path.module}/cluster-issuers.yaml")
}
