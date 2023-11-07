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

resource "null_resource" "apply_cluster_issuers" {
  depends_on = [helm_release.cert_manager]
  triggers = {
    file_sha = filesha1("${path.module}/cluster-issuers.yaml")
  }
  provisioner "local-exec" {
    command = "kubectl --kubeconfig ~/.kube/hcloud-config apply -f ${path.module}/cluster-issuers.yaml"
  }
}

resource "null_resource" "apply_argo_cert" {
  depends_on = [null_resource.apply_cluster_issuers]
  triggers = {
    file_sha = filesha1("${path.module}/argo-certificate.yaml")
  }
  provisioner "local-exec" {
    command = "kubectl --kubeconfig ~/.kube/hcloud-config apply -f ${path.module}/argo-certificate.yaml"
  }
}
