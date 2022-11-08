variable "project" {}
variable "region" {}
variable "name_prefix" {
  type    = string
  default = "prosa-"
}

variable "allowed_sources_internal_prod" {}