
provider "google-beta" {
}

resource "google_project" "deployment_zone" {
  project_id = var.provision_project_id
  name       = "CloudWright Deployment Zone"
  billing_account = var.billing_account
}

resource "google_project_service" "billing" {
  project = google_project.deployment_zone.project_id
  service = "cloudbilling.googleapis.com"
  disable_dependent_services = true
}

resource "google_project_service" "compute" {
  project = google_project.deployment_zone.project_id
  service = "compute.googleapis.com"
  disable_dependent_services = true
  depends_on = [google_project_service.billing]
}

resource "google_project_service" "vpcaccess" {
  project = google_project.deployment_zone.project_id
  service = "vpcaccess.googleapis.com"
  disable_dependent_services = true
}

data "google_compute_network" "target_network" {
  name = var.target_network
  project = var.target_network_project
}

resource "google_compute_network" "bridge_network" {
  name                    = "cloudwright-vpc-bridge"
  auto_create_subnetworks = "false"
  project = google_project.deployment_zone.project_id

  depends_on = [google_project_service.compute]
}

resource "google_compute_network_peering" "peering1" {
  name         = "peering1"
  network      = google_compute_network.bridge_network.self_link
  peer_network = data.google_compute_network.target_network.self_link
}

resource "google_compute_network_peering" "peering2" {
  name         = "peering2"
  network      = data.google_compute_network.target_network.self_link
  peer_network = google_compute_network.bridge_network.self_link
}

resource "google_vpc_access_connector" "cloudwright_connector" {
  name          = "cloudwright"
  provider      = google-beta
  region        = "us-central1"
  ip_cidr_range = var.connector_cidr_block
  project = google_project.deployment_zone.project_id
  network       = google_compute_network.bridge_network.name
  depends_on    = [google_project_service.vpcaccess]
}
