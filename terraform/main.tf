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

resource "time_sleep" "wait_for_cloud_init" {
  depends_on      = [hcloud_server.k3s_control_plane]
  create_duration = "2m"
}


resource "null_resource" "get_kubeconfig" {
  depends_on = [time_sleep.wait_for_cloud_init]
  provisioner "local-exec" {
    command = "scp -i ~/.ssh/hcloud saho@${hcloud_server.k3s_control_plane.ipv4_address}:~/.kube/config ~/.kube/hcloud-config && sed -n -i 's/127.0.0.1/${hcloud_server.k3s_control_plane.ipv4_address}/' ~/.kube/hcloud-config"
  }
}
