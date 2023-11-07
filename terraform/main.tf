resource "hcloud_ssh_key" "hcloud_key" {
  name       = "hcloud_key"
  public_key = file("~/.ssh/hcloud.pub")
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
    private_key = file("~/.ssh/hcloud")
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
    # This will fail if cloud-init restarts the machine
    on_failure = continue
    inline = [
      "cloud-init status --wait"
    ]
  }

  # Wait for kubeconfig
  provisioner "remote-exec" {
    inline = [
      "while [ ! -f ~/.kube/config ]; do sleep 5; done"
    ]
  }
}


resource "null_resource" "get_kubeconfig" {
  depends_on = [null_resource.wait_for_cloud_init]

  # Remove the host from known_hosts
  provisioner "local-exec" {
    command = "ssh-keygen -f ~/.ssh/known_hosts -R ${hcloud_server.k3s_control_plane.ipv4_address}"
  }
  provisioner "local-exec" {
    command = "scp -o StrictHostKeyChecking=accept-new -i ~/.ssh/hcloud saho@${hcloud_server.k3s_control_plane.ipv4_address}:~/.kube/config ~/.kube/hcloud-config && sed -i 's/127.0.0.1/${hcloud_server.k3s_control_plane.ipv4_address}/' ~/.kube/hcloud-config"
  }
}
