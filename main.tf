variable "credentials" {}
variable "project" {}
variable "region" {}
variable "zone" {}
variable "name" {}
variable "image" {}
variable "disk" {}
variable "public_key" {}

provider "google" {
  credentials = "${var.credentials}"
  project     = "${var.project}"
  region      = "${regex("(.*)-", var.zone)}[0]"
  zone        = "${var.zone}"
}

resource "google_compute_instance" "instance" {
  name         = "${var.name}"
  machine_type = "n1-standard-1"
  tags         = ["hobbyfarm"]

  boot_disk {
    initialize_params {
      image = "${var.image}"
      size = "${var.disk}"
    }
  }

  metadata = {
    ssh-keys = "ubuntu:${var.public_key}"
  }

  network_interface {
    network       = "default"
    access_config = {
      // Ephemeral IP - leaving this block empty will generate a new external IP and assign it to the machine
    }
  }

}

output "private_ip" {
  value = "${google_compute_instance.instance.network_interface.0.network_ip}"
}

output "public_ip" {
   value = "${google_compute_instance.instance.network_interface.0.access_config.0.nat_ip}"
}

output "hostname" {
  value = "${google_compute_instance.instance.network_interface.0.access_config.0.public_ptr_domain_name}"
}
