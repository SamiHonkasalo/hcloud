resource "helm_release" "argocd" {
  depends_on       = [null_resource.apply_argo_cert]
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  version          = "5.46.7"
  namespace        = "argocd"
  create_namespace = true

  values = [
    "${file("${path.module}/argocd-values.yaml")}"
  ]
}


resource "null_resource" "deploy_argo_apps" {
  depends_on = [helm_release.argocd]
  triggers = {
    dir_sha  = sha1(join("", [for f in fileset("${path.module}/../applications", "*.yaml") : filesha1("${"${path.module}/../applications"}/${f}")]))
    file_sha = filesha1("${path.module}/argocd-applications.yaml")
  }
  provisioner "local-exec" {
    command = "kubectl --kubeconfig ~/.kube/hcloud-config apply -f ${path.module}/argocd-applications.yaml"
  }
}
