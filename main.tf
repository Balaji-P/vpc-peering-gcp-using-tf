
provider "google-beta" {
}

resource "google_project" "deployment-zone" {
  project_id = var.provision-project-id
  name       = "CloudWright Deployment Zone"
  billing_account = var.billing-account
}

resource "google_project_service" "billing" {
  project = google_project.deployment-zone.project_id
  service = "cloudbilling.googleapis.com"
  disable_dependent_services = true
}

resource "google_project_service" "compute" {
  project = google_project.deployment-zone.project_id
  service = "compute.googleapis.com"
  disable_dependent_services = true
  depends_on = [google_project_service.billing]
}

resource "google_project_service" "vpcaccess" {
  project = google_project.deployment-zone.project_id
  service = "vpcaccess.googleapis.com"
  disable_dependent_services = true
}

data "google_compute_network" "target-network" {
  name = var.target-network
  project = var.target-network-project
}

resource "google_compute_network" "bridge-network" {
  name                    = "cloudwright-vpc-bridge"
  auto_create_subnetworks = "false"
  project = google_project.deployment-zone.project_id

  depends_on = [google_project_service.compute]
}

resource "google_compute_network_peering" "peering1" {
  name         = "peering1"
  network      = google_compute_network.bridge-network.self_link
  peer_network = data.google_compute_network.target-network.self_link
}

resource "google_compute_network_peering" "peering2" {
  name         = "peering2"
  network      = data.google_compute_network.target-network.self_link
  peer_network = google_compute_network.bridge-network.self_link
}

resource "google_vpc_access_connector" "cloudwright-connector" {
  name          = "cloudwright"
  provider      = google-beta
  region        = "us-central1"
  ip_cidr_range = var.connector-cidr-block
  project = google_project.deployment-zone.project_id
  network       = google_compute_network.bridge-network.name
  depends_on    = [google_project_service.vpcaccess]
}
