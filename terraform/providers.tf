provider "hcloud" {
  token = var.hcloud_token
}

provider "helm" {
  kubernetes {
    host                   = local.kubeconfig_data.host
    cluster_ca_certificate = local.kubeconfig_data.cluster_ca_certificate
    client_certificate     = local.kubeconfig_data.client_certificate
    client_key             = local.kubeconfig_data.client_key
  }
}

provider "kubernetes" {
  host                   = local.kubeconfig_data.host
  cluster_ca_certificate = local.kubeconfig_data.cluster_ca_certificate
  client_certificate     = local.kubeconfig_data.client_certificate
  client_key             = local.kubeconfig_data.client_key
}

provider "kubectl" {
  load_config_file = false
  host                   = local.kubeconfig_data.host
  cluster_ca_certificate = local.kubeconfig_data.cluster_ca_certificate
  client_certificate     = local.kubeconfig_data.client_certificate
  client_key             = local.kubeconfig_data.client_key
  apply_retry_count = 2
}
