provider "hcloud" {
  token = var.hcloud_token
}

provider "helm" {
  kubernetes {
    config_path = "/tmp/.kube/hcloud-config"
  }
}

provider "kubernetes" {
  config_path = "/tmp/.kube/hcloud-config"
}

provider "kubectl" {
  config_path = "/tmp/.kube/hcloud-config"
}
