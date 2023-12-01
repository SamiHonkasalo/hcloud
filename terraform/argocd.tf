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

resource "kubernetes_config_map_v1_data" "configure_argocd_auth" {
  depends_on = [kubernetes_secret.argocd_auth_secrets]
  force      = true
  metadata {
    name      = "argocd-cm"
    namespace = "argocd"
  }
  data = {
    "admin.enabled"                = "false"
    "application.instanceLabelKey" = "argocd.argoproj.io/instance"
    "url"                          = "https://argocd.k3sdemo.saho.dev"
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
    - groups
    EOT
  }
}

resource "kubernetes_config_map_v1_data" "configure_argocd_rbac" {
  depends_on = [kubernetes_secret.argocd_auth_secrets]
  force      = true
  metadata {
    name      = "argocd-rbac-cm"
    namespace = "argocd"
  }
  data = {
    # No default role
    "policy.default" = ""
    "scopes"         = "[groups]"
    "policy.csv"     = <<-EOT
    g, argocd-admin, role:admin
    EOT
  }
}

resource "kubectl_manifest" "argocd_applications" {
  depends_on = [helm_release.argocd]
  yaml_body  = file("${path.module}/argocd-applications.yaml")
}
