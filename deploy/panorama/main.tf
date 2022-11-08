data "google_compute_zones" "this" {}

# Creating Panorama in a different region to overcome qwiklabs 
module "vpc" {
  source  = "PaloAltoNetworks/vmseries-modules/google//modules/vpc"
  version = "0.3.0"

  networks = [
    # Panorama
    {
      name            = "${var.name_prefix}shared-services"
      subnetwork_name = "${var.name_prefix}shared-services"
      ip_cidr_range   = var.ip_cidr_range_panorama
      allowed_sources = var.allowed_sources_mgmt
    },
  ]
}


module "panorama" {
  source  = "PaloAltoNetworks/vmseries-modules/google//modules/panorama"
  version = "0.3.0"

  for_each = var.panorama

  name   = each.key
  region = var.region
  subnet = module.vpc.subnetworks["${var.name_prefix}shared-services"].self_link
  zone   = data.google_compute_zones.this.names[0]

  custom_image      = var.custom_image

  attach_public_ip  = var.panorama_common.attach_public_ip
  private_static_ip = each.value.private_static_ip

  disk_type = var.panorama_common.disk_type
  ssh_keys  = "admin:${file(var.public_key_path)}"

  log_disks = [
    {
      name = "${each.key}-log1"
      type = var.panorama_common.log_disks.type
      size = var.panorama_common.log_disks.size
    }
  ]

  tags = ["panorama"]
}

# Panorama administrative access
resource "google_compute_firewall" "mgmt" {
  name    = "${var.name_prefix}panorama-mgmt"
  network = module.vpc.networks["${var.name_prefix}shared-services"].self_link

  allow {
    protocol = "tcp"
    ports    = [22, 443]
  }

  source_ranges = var.allowed_sources_mgmt
  target_tags   = ["panorama"]
}

# VM-Series to Panorama access
resource "google_compute_firewall" "vmseries" {
  name    = "${var.name_prefix}panorama-vmseries"
  network = module.vpc.networks["${var.name_prefix}shared-services"].self_link

  allow {
    protocol = "all"
  }

  source_tags = ["vmseries"]
  target_tags = ["panorama"]
}


create_network=false