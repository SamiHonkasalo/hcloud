provider "hcloud" {
  token = var.hcloud_token
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/hcloud-config"
  }
}

provider "kubernetes" {
  config_path = "~/.kube/hcloud-config"
}
