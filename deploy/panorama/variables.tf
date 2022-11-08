variable "project" {}
variable "region" {}
variable "name_prefix" {
  type    = string
  default = "gcp-lab-"
}

variable "ip_cidr_range_panorama" {}
variable "allowed_sources_mgmt" {}

variable "panorama" {}
variable "panorama_common" {}
variable "public_key_path" {}
variable "custom_image" {}