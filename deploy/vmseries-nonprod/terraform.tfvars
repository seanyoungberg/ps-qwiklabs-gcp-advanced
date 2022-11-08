# Common
project     = "" # UPDATE HERE
region      = "us-central1"
name_prefix = "gcp-lab-"

# Networking
ip_cidr_range_fw_mgmt         = "10.217.38.0/28"
ip_cidr_range_fw_internet     = "10.217.37.128/25"
ip_cidr_range_fw_inside_shared_services = "10.217.37.0/25"
ip_cidr_range_fw_inside_prod     = "10.216.38.32/27"

google_healthcheck_sources = [
  "35.191.0.0/16", "130.211.0.0/22", "209.85.152.0/22", "209.85.204.0/22", "169.254.169.254/32"
]

allowed_sources_fw_mgmt         = ["0.0.0.0/0"] # UPDATE HERE
allowed_sources_fw_internet     = ["0.0.0.0/0"]
allowed_sources_fw_inside_shared_services = ["10.0.0.0/8"]
allowed_sources_fw_inside_prod     = ["10.0.0.0/8"]

# VM-Series
vmseries = {}
vmseries_common = {
  image                 = "projects/paloaltonetworksgcp-public/global/images/vmseries-flex-byol-1023"
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
    panorama-server             = "10.210.38.5"     # UPDATE HERE
    tplname                     = "gcp-lab-stack"        # UPDATE HERE
    dgname                      = "gcp-lab" # UPDATE HERE
  }

}