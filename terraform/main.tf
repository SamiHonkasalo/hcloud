resource "hcloud_ssh_key" "hcloud_key" {
  name       = "hcloud_key"
  public_key = var.hcloud_pub_key
}

resource "hcloud_server" "k3s_control_plane" {
  name        = var.server_name
  image       = var.server_image
  server_type = var.server_type
  datacenter  = var.datacenter
  ssh_keys    = [hcloud_ssh_key.hcloud_key.id]
  user_data   = file("${path.module}/../cloud-config.yaml")
}

resource "null_resource" "wait_for_cloud_init" {
  connection {
    user        = "saho"
    host        = hcloud_server.k3s_control_plane.ipv4_address
    private_key = var.hcloud_private_key
  }
  provisioner "remote-exec" {
    # This will fail if cloud-init restarts the machine
    on_failure = continue
    inline = [
      "cloud-init status --wait"
    ]
  }
  provisioner "remote-exec" {
    # This will fail if cloud-init restarts the machine
    on_failure = continue
    inline = [
      "cloud-init status --wait"
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "cloud-init status --wait"
    ]
  }
}

locals {
  k3s_version = "v1.28.3+k3s2"
  k3s_args    = "--disable=traefik --kube-apiserver-arg=oidc-issuer-url=https://sahodev.eu.auth0.com/ --kube-apiserver-arg=oidc-client-id=${var.auth0_clientId_k3s} --kube-apiserver-arg=oidc-username-claim=email --kube-apiserver-arg=oidc-groups-claim=groups"
}

resource "null_resource" "install_k3s" {
  depends_on = [null_resource.wait_for_cloud_init]
  triggers = {
    version = local.k3s_version
    args    = local.k3s_args
  }
  connection {
    user        = "saho"
    host        = hcloud_server.k3s_control_plane.ipv4_address
    private_key = var.hcloud_private_key
  }

  # Install k3s
  provisioner "remote-exec" {
    inline = [
      "curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION='${local.k3s_version}' sh -s - ${local.k3s_args}",
    ]
  }

  # Wait for installation to finish
  provisioner "remote-exec" {
    inline = [
      "while [ ! -f /etc/rancher/k3s/k3s.yaml ]; do sleep 5; done",
      "sudo mkdir -p /home/saho/.kube",
      "sudo /bin/cp -f /etc/rancher/k3s/k3s.yaml /home/saho/.kube/config",
      "sudo chown saho /home/saho/.kube/config"
    ]
  }
}


resource "null_resource" "get_kubeconfig" {
  depends_on = [null_resource.install_k3s]

  # Save the ssh key into a temp file
  provisioner "local-exec" {
    command = "echo '${var.hcloud_private_key}' > ~/hcloud-ssh"
  }
  provisioner "local-exec" {
    command = "scp -o StrictHostKeyChecking=accept-new -i ~/hcloud-ssh saho@${hcloud_server.k3s_control_plane.ipv4_address}:~/.kube/config ~/.kube/hcloud-config && sed -i 's/127.0.0.1/${hcloud_server.k3s_control_plane.ipv4_address}/' ~/.kube/hcloud-config"
  }
}
