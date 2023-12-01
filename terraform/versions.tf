terraform {
  required_version = ">= 1.5.7"

  cloud {
    organization = "sahodev"

    workspaces {
      name = "hcloud"
    }
  }

  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "1.44.1"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.11.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.23.0"
    }
    remote = {
      source  = "tenstad/remote"
      version = "0.1.2"
    }
    local = {
      source  = "hashicorp/local"
      version = ">= 2.4.0"
    }
    kubectl = {
      source  = "alekc/kubectl"
      version = "2.0.3"
    }
  }
}
