resource "random_password" "cookie_secret" {
  length           = 32
  override_special = "-_"
}

resource "helm_release" "oauth2_proxy" {
  depends_on       = [helm_release.cert_manager]
  name             = "oauth2-proxy"
  repository       = "https://oauth2-proxy.github.io/manifests"
  chart            = "oauth2-proxy"
  version          = "6.19.0"
  namespace        = "oauth2-proxy"
  create_namespace = true
  set {
    name  = "config.clientID"
    value = var.auth0_clientId_k3s
  }
  set {
    name  = "config.clientSecret"
    value = var.auth0_clientSecret_k3s
  }
  set {
    name  = "config.cookieSecret"
    value = random_password.cookie_secret.result
  }

  set {
    name  = "extraArgs"
    value = <<-EOT
    provider: oidc
    provider-display-name: Auth0
    oidc-issues-url: https://sahodev.eu.auth0.com
    skip-provider-button: true
    pass-access-token: true
    upstreams: file:///dev/null
    EOT
  }

}
