variable "hcloud_token" {
  type      = string
  sensitive = true
}

variable "auth0_clientSecret" {
  type      = string
  sensitive = true
}
variable "auth0_clientId" {
  default = "UbHldl65BIesetdNMSX20YVNVnalkkkN"
}
variable "auth0_clientId_k3s" {
  default = "fj0v4NQ8mM5ozkZxntj4mzwOCzOSR4xQ"
}
variable "auth0_clientSecret_k3s" {
  type      = string
  sensitive = true
}

variable "server_name" {
  default = "k3s-control-plane"
}

variable "server_type" {
  default = "cpx11"
}

variable "datacenter" {
  default = "hel1-dc2"
}

variable "server_image" {
  default = "ubuntu-22.04"
}
