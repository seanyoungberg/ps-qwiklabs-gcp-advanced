# Common
project     = "" # UPDATE HERE
region      = "europe-west4"
name_prefix = "gcp-lab-"

# Networking
ip_cidr_range_panorama = "10.210.38.0/28" # UPDATE HERE!
allowed_sources_mgmt   = ["0.0.0.0/0"] # For production deployments this should be limited to known sources

# Panorama
panorama = {
  panorama1 = {
    private_static_ip = "10.210.38.5" # UPDATE HERE
    }
}

panorama_common = {
  attach_public_ip = true
  disk_type        = "pd-standard"
  log_disks = {
    type = "pd-standard"
    size = "2000"
  }
}

public_key_path = "~/.ssh/gcp-lab-key.pem"
custom_image = "projects/panw-gcp-team-testing/global/images/panorama-1023"