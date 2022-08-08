variable "credentials" {}
variable "project" {}
variable "zone" {}
variable "name" {}
variable "access_code" {
  default = ""
}
variable "machine_type" {
  default = "n1-standard-1"
}
variable "course" {
  default = "course:none"
}
variable "image" {
  default = "ubuntu-1804-lts"
}
variable "disk" {
  default = "10"
}
variable "public_key" {}
variable "ssh_user" {
  default = "ubuntu"
}
variable "cloud_init" {}

provider "google" {
  version     = "2.9.1"
  credentials = "${var.credentials}"
  project     = "${var.project}"
  region      = "${replace(var.zone, "/-[a-z]$/", "")}"
  zone        = "${var.zone}"
}

resource "google_compute_instance" "instance" {
  name         = "${var.name}"
  machine_type = "${var.machine_type}"
  tags         = ["hobbyfarm"]
  labels       = {
    access_code = "${var.access_code}"
    course = "${var.course}"
  }
  boot_disk {
    initialize_params {
      image = "${var.image}"
      size = "${var.disk}"
    }
  }

  metadata = {
    ssh-keys = "${var.ssh_user}:${var.public_key}"
    user-data = "${var.cloud_init}"
  }

  network_interface {
    network       = "default"
    access_config {
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
