# Common
project     = "" # UPDATE HERE
region      = "us-central1"
name_prefix = "gcp-lab-"
public_key_path = "~/.ssh/gcp-lab-key.pub"

# Networking
ip_cidr_range_fw_mgmt         = "10.217.38.0/28"
ip_cidr_range_fw_internet     = "10.217.37.128/25"
ip_cidr_range_fw_inside_shared_services = "10.217.37.0/25"
ip_cidr_range_fw_inside_prod     = "10.216.38.32/27"
ip_cidr_range_prod     = "10.218.0.0/16"

google_healthcheck_sources = [
  "35.191.0.0/16", "130.211.0.0/22", "209.85.152.0/22", "209.85.204.0/22", "169.254.169.254/32"
]

allowed_sources_fw_mgmt         = ["0.0.0.0/0"] # In Real Deployment, this should be limited to known sources
allowed_sources_fw_internet     = ["0.0.0.0/0"]
allowed_sources_fw_inside_shared_services = ["10.0.0.0/8"]
allowed_sources_fw_inside_prod     = ["10.0.0.0/8"]
allowed_sources_prod = ["10.0.0.0/8"]

# VM-Series
#vmseries = {}
vmseries_common = {
  image                 = "projects/paloaltonetworksgcp-public/global/images/vmseries-flex-byol-1022h2"
  machine_type          = "n1-standard-4"
  # min_cpu_platform      = "Intel Cascade Lake"
  vmseries_per_zone_min = 1
  vmseries_per_zone_max = 2
  metadata = {
    type                        = "dhcp-client"
    dhcp-send-hostname          = "yes"
    dhcp-send-client-id         = "yes"
    dhcp-accept-server-hostname = "yes"
    dhcp-accept-server-domain   = "yes"
    op-command-modes            = "mgmt-interface-swap"
    plugin-op-commands          = "panorama-licensing-mode-on"
    auth-key                    = "" # UPDATE HERE
    panorama-server             = "10.210.38.5"
    tplname                     = "gcp-lab-stack"
    dgname                      = "gcp-lab"
  }

}

## Test VMs

vm_image = "https://www.googleapis.com/compute/v1/projects/panw-gcp-team-testing/global/images/ubuntu-2004-lts-apache"
vm_type  = "f1-micro"