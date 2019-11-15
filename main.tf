variable "credentials" {}
variable "project" {}
variable "region" {}
variable "zone" {}
variable "name" {}
variable "image" {}
variable "disk" {}
variable "public_key" {}
variable "ssh_user" {}

provider "google" {
  credentials = "${var.credentials}"
  project     = "${var.project}"
  region      = "${var.region}"
  zone        = "${var.zone}"
}

resource "google_compute_instance" "instance" {
  name         = "${var.name}"
  machine_type = "n1-standard-1"
  tags         = ["hobbyfarm"]

  boot_disk {
    initialize_params {
      image = "${var.image}"
    }
  }

  metadata = {
    ssh-keys = "${var.ssh_user}:${var.public_key}"
  }

  network_interface {
    network       = "default"
    access_config = {
      // Ephemeral IP - leaving this block empty will generate a new external IP and assign it to the machine
    }
  }

  initialize_params {
    size = "${var.disk}"
  }
}

output "private_ip" {
  value = "${google_compute_instance.instance.nat_ip}"
}

output "public_ip" {
   value = ["${google_compute_instance.instance.*.network_interface.0.access_config.0.assigned_nat_ip}"]
}

output "hostname" {
  value = "${google_compute_instance.instance.hostname}"
}
