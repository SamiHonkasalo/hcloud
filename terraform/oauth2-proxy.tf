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
    name  = "extraArgs.provider"
    value = "oidc"
  }
  set {
    name  = "extraArgs.provider-display-name"
    value = "Auth0"
  }
  set {
    name  = "extraArgs.oidc-issuer-url"
    value = "https://sahodev.eu.auth0.com/"
  }
  set {
    name  = "extraArgs.oidc-groups-claim"
    value = "groups"
  }
  set {
    name  = "extraArgs.skip-provider-button"
    value = "true"
  }
  set {
    name  = "extraArgs.pass-access-token"
    value = "true"
  }
  set {
    name  = "extraArgs.pass-authorization-header"
    value = "true"
  }
  set {
    name  = "extraArgs.set-authorization-header"
    value = "true"
  }
  set {
    name  = "extraArgs.set-xauthrequest"
    value = "true"
  }
}
