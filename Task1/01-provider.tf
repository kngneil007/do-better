terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "5.29.1"
    }
  }
}


provider "google" {
  # Configuration options
  project     = var.project_id
  region      = var.region
  zone        = var.zone
  credentials = var.credentials
}