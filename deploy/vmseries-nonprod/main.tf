data "google_compute_zones" "this" {}

module "vpc" {
  source  = "PaloAltoNetworks/vmseries-modules/google//modules/vpc"
  version = "0.3.0"

  networks = [
    # VM-Series
    {
      name            = "${var.name_prefix}fw-internet"
      subnetwork_name = "${var.name_prefix}fw-internet"
      ip_cidr_range   = var.ip_cidr_range_fw_internet
      allowed_sources = var.allowed_sources_fw_internet
    },
    {
      name            = "${var.name_prefix}fw-inside-prod"
      subnetwork_name = "${var.name_prefix}fw-inside-prod"
      ip_cidr_range   = var.ip_cidr_range_fw_inside_prod
      allowed_sources = setunion(var.google_healthcheck_sources, var.allowed_sources_fw_inside_prod)
      delete_default_routes_on_create = true
    },
    {
      name                            = "${var.name_prefix}fw-inside-shared-services"
      subnetwork_name                 = "${var.name_prefix}fw-inside-shared-services"
      ip_cidr_range                   = var.ip_cidr_range_fw_inside_shared_services
      delete_default_routes_on_create = true
      allowed_sources                 = setunion(var.google_healthcheck_sources, var.allowed_sources_fw_inside_shared_services)
      delete_default_routes_on_create = true
    },
    {
      name                            = "${var.name_prefix}fw-inside-shared-services"
      subnetwork_name                 = "${var.name_prefix}fw-inside-shared-services"
      ip_cidr_range                   = var.ip_cidr_range_fw_inside_shared_services
      delete_default_routes_on_create = true
      allowed_sources                 = setunion(var.google_healthcheck_sources, var.allowed_sources_fw_inside_shared_services)
      delete_default_routes_on_create = true
    }
  ]
}

data "google_compute_network" "shared-services" {
  name = "${var.name_prefix}shared-services"
}

# Creating FW mgmt subnets in existing shared services VPC due to QwikLabs VPC quota
module "vpc-fw-mgmt" {
  
  source  = "PaloAltoNetworks/vmseries-modules/google//modules/vpc"
  version = "0.3.0"

  networks = [
    # FW Mgmt Subnet
    {
      create_network  = false
      name            = "${var.name_prefix}shared-services"
      subnetwork_name = "${var.name_prefix}fw-mgmt"
      ip_cidr_range   = var.ip_cidr_range_fw_mgmt
      #allowed_sources = var.allowed_sources_fw_mgmt
    },
  ]
}

# resource "google_compute_network_peering" "panorama_to_mgmt_nonprod" {
#   name                 = "${var.name_prefix}panorama-to-mgmt"
#   network              = data.google_compute_network.panorama.id
#   peer_network         = module.vpc.networks["${var.name_prefix}mgmt"].id
#   export_custom_routes = true
#   import_custom_routes = false
# }

# resource "google_compute_network_peering" "mgmt_nonprod_to_panorama" {
#   name                 = "${var.name_prefix}mgmt-to-panorama"
#   network              = module.vpc.networks["${var.name_prefix}mgmt"].id
#   peer_network         = data.google_compute_network.panorama.id
#   export_custom_routes = false
#   import_custom_routes = true
# }


resource "google_compute_router" "router" {
  name    = "mgmt-cloud-router"
  network = data.google_compute_network.shared-services.id

  bgp {
    asn = 64514
  }
}

resource "google_compute_router_nat" "nat" {
  name                               = "mgmt-cloud-nat"
  router                             = google_compute_router.router.name
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"
  subnetwork {
    name                    = module.vpc-fw-mgmt.subnetworks["${var.name_prefix}fw-mgmt"].id
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}