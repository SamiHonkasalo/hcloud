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

resource "kubernetes_secret" "argocd_auth_secrets" {
  depends_on = [helm_release.argocd]
  metadata {
    name      = "argocd-auth-secrets"
    namespace = "argocd"
    labels = {
      "app.kubernetes.io/part-of" = "argocd"
    }
  }
  type = "Opaque"
  data = {
    "oidc.auth0.clientSecret" = base64encode(var.auth0_clientSecret)
    "oidc.auth0.clientId"     = base64encode(var.auth0_clientId)
  }
}

resource "kubernetes_config_map_v1_data" "configure_argocd_auth" {
  depends_on = [kubernetes_secret.argocd_auth_secrets]
  force = true
  metadata {
    name      = "argocd-cm"
    namespace = "argocd"
  }
  data = {
    "admin.enabled"                = "false"
    "application.instanceLabelKey" = "argocd.argoproj.io/instance"
    "url"                          = "https://argocd.k3s.saho.dev"
    "oidc.config"                  = <<EOT
    name: Auth0
    issuer: https://sahodev.eu.auth0.com/
    clientID: ${var.auth0_clientId}
    clientSecret: $argocd-auth-secrets:oidc.auth0.clientSecret
    requestedScopes:
    - openid
    - profile
    - email
    #- "http://sahodev.eu.auth0.com/groups"
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
