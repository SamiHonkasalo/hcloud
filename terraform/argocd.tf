resource "helm_release" "argocd" {
  depends_on       = [helm_release.cert_manager]
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

resource "kubernetes_secret" "argocd_auth_secrets" {
  depends_on = [helm_release.argocd]
  metadata {
    name      = "argocd-auth-secret"
    namespace = "argocd"
    labels = {
      "app.kubernetes.io/part-of" = "argocd"
    }
  }
  type = "Opaque"
  data = {
    "oidc.auth0.clientSecret" = var.auth0_clientSecret
  }
}

resource "kubernetes_config_map" "configure_argocd_auth" {
  depends_on = [kubernetes_secret.argocd_auth_secrets]
  metadata {
    name      = "argocd-cm"
    namespace = "argocd"
  }
  data = {
    "admin.enabled"                = "false"
    "exec.enabled"                 = "false"
    "timeout.reconciliation"       = "180s"
    "timeout.hard.reconciliation"  = "0s"
    "application.instanceLabelKey" = "argocd.argoproj.io/instance"
    "url"                          = "https://argocd.k3s.saho.dev"
    "oidc.config"                  = <<-EOT
    name: Auth0
    issuer: https://sahodev.eu.auth0.com/
    cliClientID: ${var.auth0_clientId}
    clientID: ${var.auth0_clientId}    
    clientSecret: $argocd-auth-secret:oidc.auth0.clientSecret
    requestedScopes:
    - openid
    - profile
    - email
    EOT
  }
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
