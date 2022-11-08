module "svc_account" {
  source  = "PaloAltoNetworks/vmseries-modules/google//modules/iam_service_account/"
  version = "0.3.0"

  service_account_id = "${var.name_prefix}vmseries"
}

module "vmseries" {
  source  = "PaloAltoNetworks/vmseries-modules/google//modules/autoscale"
  version = "0.3.0"

  # project_id = var.project
  region = var.region
  zones = {
    zone1 = data.google_compute_zones.this.names[0]
    zone2 = data.google_compute_zones.this.names[1]
  }

  prefix          = "${var.name_prefix}vmseries"
  deployment_name = "${var.name_prefix}vmseries"

  image            = var.vmseries_common.image
  machine_type     = var.vmseries_common.machine_type
  # min_cpu_platform = var.vmseries_common.min_cpu_platform
  # public_key_path = "~/.ssh/id_ed25519.pub"

  pool                  = module.elb_internet.target_pool
  scopes                = ["https://www.googleapis.com/auth/cloud-platform"]
  service_account_email = module.svc_account.email
  min_replicas_per_zone = var.vmseries_common.vmseries_per_zone_min
  max_replicas_per_zone = var.vmseries_common.vmseries_per_zone_max
  metadata              = var.vmseries_common.metadata

  network_interfaces = [
    {
      subnetwork       = module.vpc.subnetworks["${var.name_prefix}fw-internet"].self_link
      create_public_ip = false
    },
    {
      subnetwork       = module.vpc-fw-mgmt.subnetworks["${var.name_prefix}fw-mgmt"].self_link
      create_public_ip = false
    },
    {
      subnetwork       = module.vpc.subnetworks["${var.name_prefix}fw-inside-prod"].self_link
      create_public_ip = false
    },
    {
      subnetwork       = module.vpc.subnetworks["${var.name_prefix}fw-inside-shared-services"].self_link
      create_public_ip = false
    },
  ]

  # metadata = {
  #   type                        = "dhcp-client"
  #   op-command-modes            = "mgmt-interface-swap"
  #   vm-auth-key                 = var.panorama_vm_auth_key
  #   panorama-server             = var.panorama_address
  #   dgname                      = var.panorama_device_group
  #   tplname                     = var.panorama_template_stack
  #   dhcp-send-hostname          = "yes"
  #   dhcp-send-client-id         = "yes"
  #   dhcp-accept-server-hostname = "yes"
  #   dhcp-accept-server-domain   = "yes"
  #   dns-primary                 = "8.8.8.8"
  #   dns-secondary               = "4.2.2.2"
  # }

  # named_ports = [
  #   {
  #     name = "http"
  #     port = "80"
  #   },
  # ]

  tags = ["vmseries"]
}

module "ilb_internal" {
  source = "PaloAltoNetworks/vmseries-modules/google//modules/lb_internal/"
  version = "0.3.0"

  name                = "${var.name_prefix}fw-inside-prod"
  network             = module.vpc.networks["${var.name_prefix}fw-inside-prod"].self_link
  subnetwork          = module.vpc.subnetworks["${var.name_prefix}fw-inside-prod"].self_link
  all_ports           = true
  backends            = module.vmseries.backends
  allow_global_access = true
  health_check_port   = 443
}

module "ilb_interconnect" {
  source = "PaloAltoNetworks/vmseries-modules/google//modules/lb_internal/"
  version = "0.3.0"

  name                = "${var.name_prefix}fw-inside-shared-services"
  network             = module.vpc.networks["${var.name_prefix}fw-inside-shared-services"].self_link
  subnetwork          = module.vpc.subnetworks["${var.name_prefix}fw-inside-shared-services"].self_link
  all_ports           = true
  backends            = module.vmseries.backends
  allow_global_access = true
  health_check_port   = 443
}

module "elb_internet" {
  source = "PaloAltoNetworks/vmseries-modules/google//modules/lb_external/"
  version = "0.3.0"

  name = "${var.name_prefix}fw-internet"
  rules = {
    ("${var.name_prefix}internet-tcp") = {
      # port_range = 80
      all_ports   = true
      ip_protocol = "TCP"
    }
  }

  health_check_http_port         = 80
  health_check_http_request_path = "/"
}