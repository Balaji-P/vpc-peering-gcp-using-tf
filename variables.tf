
variable "provision_project_id" {
  type        = string
  description  = "Project to create and provision infrastructure in"
}

variable "target_network" {
  type        = string
  description  = "VPC network name to attach to"
}

variable "target_network_project" {
  type        = string
  description  = "Project containing target VPC network"
}

variable "connector_cidr_block" {
  type        = string
  description  = "CIDR block to provide to Serverless Access Connector (must be a /28)"
}

variable "connector_region" {
  type        = string
  description  = "Region to provision access connector (should be the same region as intended Deployment Zone)"
}

variable "billing_account" {
  type        = string
  description  = "Billing account ID, used during project provisioning"
}