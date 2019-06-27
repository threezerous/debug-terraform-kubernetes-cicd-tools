variable "app_repo" {}
variable "size" {}
variable "public_key" {}
variable "private_key" {}

locals {
  yum   = "sudo yum -y -d 1 install"
  image = "centos-7-v20180129"
  user  = "centos"
}

resource "google_compute_instance" "build" {
  name         = "build"
  machine_type = "${var.size}"

  boot_disk {
    initialize_params {
      image = "${local.image}"
    }
  }

  network_interface {
    network       = "${data.google_compute_network.net.name}"
    access_config{
    }
  }

  metadata = {
    sshKeys = "${local.user}:${file(var.public_key)}"
  }

  // Apply the firewall rule to allow external IPs to access this instance
  tags = ["jenkins-server"]

  connection {
    user        = "${local.user}"
    private_key = "${file(var.private_key)}"
    host = "${google_compute_instance.build.network_interface.0.access_config.0.assigned_nat_ip}"
  }

  provisioner "file" {
    source      = "jenkins"
    destination = "~"
  }

}

output "build" {
  value = "${google_compute_instance.build.network_interface.0.access_config.0.nat_ip}:8080"
}
