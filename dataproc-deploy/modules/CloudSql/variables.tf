variable "project_id" {
  type = string
}

variable "region" {
  type = string
}

variable "prefix" {
  type = string
}
variable "network_id" {
  default = ""
}

# VPC self_link from your VPC module output
variable "network_self_link" {
  type        = string
  description = "Self link of the VPC network for Private IP"
}

