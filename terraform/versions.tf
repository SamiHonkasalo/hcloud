terraform {
  required_version = ">= 1.5.7"

  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "1.44.1"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.11.0"
    }
  }
}
