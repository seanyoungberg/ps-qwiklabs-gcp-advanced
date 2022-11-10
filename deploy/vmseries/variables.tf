variable "project" {}
variable "region" {}
variable "name_prefix" {
  type    = string
  default = "gcp-lab-"
}

variable "ip_cidr_range_fw_mgmt" {}
variable "ip_cidr_range_fw_internet" {}
variable "ip_cidr_range_fw_inside_prod" {}
variable "ip_cidr_range_fw_inside_shared_services" {}
variable "ip_cidr_range_prod" {}

variable "google_healthcheck_sources" {}

variable "allowed_sources_fw_mgmt" {}
variable "allowed_sources_fw_internet" {}
variable "allowed_sources_fw_inside_prod" {}
variable "allowed_sources_fw_inside_shared_services" {}
variable "allowed_sources_prod" {}

# variable "vmseries" {}
variable "vmseries_common" {}

variable "public_key_path" {}