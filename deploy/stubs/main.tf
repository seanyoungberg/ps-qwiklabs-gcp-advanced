module "stub_vpc" {
  source  = "PaloAltoNetworks/vmseries-modules/google//modules/vpc"
  version = "0.3.0"

  networks = [
    {
      name            = "${var.name_prefix}internal-prod"
      subnetwork_name = "${var.name_prefix}internal-prod"
      project         = "gcp-gcs-pso"
      ip_cidr_range   = "10.212.2.0/24"
      allowed_sources = var.allowed_sources_internal_prod
    },
  ]
}

output "stub_vpc" {
  value = module.stub_vpc
}