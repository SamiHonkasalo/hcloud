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
