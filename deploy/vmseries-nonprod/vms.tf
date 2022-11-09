# --------------------------------------------------------------------------------------------------------------------------
# Creates 2 Ubuntu GCE instances.  These instances are used for testing purposes.

variable "vm_image" {
  default = "ubuntu-os-cloud/ubuntu-1604-lts"
}

variable "vm_type" {
  default = "f1-micro"
}

variable "vm_user" {}

variable "vm_scopes" {
  type = list(string)

  default = [
    "https://www.googleapis.com/auth/cloud.useraccounts.readonly",
    "https://www.googleapis.com/auth/devstorage.read_only",
    "https://www.googleapis.com/auth/logging.write",
    "https://www.googleapis.com/auth/monitoring.write",
  ]
}


resource "google_compute_instance" "prod" {
  name                      = "${local.prefix_region0}-prod-workload"
  machine_type              = var.vm_type
  zone                      = data.google_compute_zones.this.names[0]
  can_ip_forward            = false
  allow_stopping_for_update = true

  metadata = {
    serial-port-enable = true
    ssh-keys           = "admin:${file(var.public_key_path)}"
  }

  network_interface {
    #    subnetwork = module.vpc_trust.subnet_self_link["trust-${var.regions[0]}"]
    subnetwork = module.vpc.subnetworks["${var.name_prefix}prod"].self_link
  }

  boot_disk {
    initialize_params {
      image = var.vm_image
    }
  }

  service_account {
    scopes = var.vm_scopes
  }

  tags = ["prod-workload"]
}
