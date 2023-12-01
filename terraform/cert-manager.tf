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

data "kubectl_path_documents" "cluster_issuers" {
  pattern = "${path.module}/cluster-issuers.yaml"
}

resource "kubectl_manifest" "apply_cluster_issuers" {
  depends_on = [helm_release.cert_manager]
  for_each   = toset(data.kubectl_path_documents.cluster_issuers.documents)
  yaml_body  = each.value
}
