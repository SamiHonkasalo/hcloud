variable "hcloud_token" {
  type      = string
  sensitive = true
}

variable "hcloud_pub_key" {
  type = string
  default = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDFKAKsgtn42Qz+ZwtIGGcqWMewTSl9DSUCthFl2yB/4k79qm7eYpZtW8TByXi5S46H0aJjYlxdcpleVtZIecbE6r5MYM6EzuQCN7oQLPz1SqQTvFwudbr+5ayOhYoS1vzHJVyp0Kz5X7JuqCTYClJL9Kn9bIwXmYpomgKo3MwjtcfXhx6Opxn3xO3lGfFrEORNd438AhQ+aD6lNgLqwgM6zyjuqsnnc/AjQV/nvAn+wupgAw76OvN9UWZWQYiP8QgVxCb9y7b/K8IYsO2xrmfxL4w0+qFRz7SnCQmxhvQ2EHiCir2iEOiyQElOyqunEYz4r5ZSlcYoEEsLUl+5bue6RXVboSfarDR26ucWIWua+n4Hz0j8lqw6ckJWdtmklU5+21VYWwa8DLbUvvD0AXU+MHBI14DM2JE5kgh62N021EIBHUdeqceIlltCCpIXrYySynvdKVLnNgyfjOifc5nPAKfh6guYGiWdLENJXCf/FB2Qa1aHFloTuLs1tD3a0f8= saho@DESKTOP-O12DSBC"
}

variable "hcloud_private_key" {
  type = string
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
