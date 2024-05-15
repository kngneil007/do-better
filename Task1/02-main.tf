# Mission: Store Critical Information on the Cloud for Future Survivors
# Objective:
# Create a publicly accessible bucket in Google Cloud Platform (GCP) using Terraform. This bucket must be prepared to store vital information that can be accessed by any future survivors.

# Tasks to Complete:
# Terraform Script
# Write a Terraform script that will create the GCP bucket.
# GitHub Push
# Push the Terraform script to your GitHub repository.
# Output Public Link
# Ensure the output file shows the public link to the bucket.
# Index.html File
# Include an index.html file within the bucket.
# Problem Statement:
# Create a GCP bucket that fulfills the following requirements:

# Use a Terraform script to create the bucket.
# Push the script to GitHub for version control and accessibility.
# Ensure the bucket's public link is available and displayed in the output.
# The bucket must contain an index.html file as a default page.
# Example:
# The final setup should provide a public link to an HTML page stored within the bucket.

# Data Required:
# Bucket Resource: The definition and configuration of the GCP bucket.
# index.html File: The HTML file to be stored within the bucket.
# Public Access: Settings to make the bucket publicly accessible.
# Algorithm:
# Define Bucket Resource:
# Use Terraform to define and create the GCP bucket.
# Configure Public Access:
# Set the necessary permissions to make the bucket public.
# Upload index.html:
# Ensure the index.html file is uploaded to the bucket.
# Output Public URL:
# Configure the output to display the public link to the bucket.



resource "google_storage_bucket" "dont-save-her" {
  name          = "dont-save-her"
  location      = var.location
  force_destroy = true
  website {
    main_page_suffix = "index.html"
    not_found_page   = "404.html"
  }
  # cors {
  #   origin          = ["http://image-store.com"]
  #   method          = ["GET", "HEAD", "PUT", "POST", "DELETE"]
  #   response_header = ["*"]
  #   max_age_seconds = 3600
  # }
  uniform_bucket_level_access = false
}

resource "google_storage_bucket_access_control" "public_rule" {
  bucket = google_storage_bucket.dont-save-her.name
  role   = "READER"
  entity = "allUsers"
}

resource "google_storage_bucket_iam_binding" "public_access" {
  bucket = google_storage_bucket.dont-save-her.name
  role   = "roles/storage.objectViewer"

  members = [
    "allUsers",
  ]
}

resource "google_storage_bucket_object" "default" {
  name         = "index.html"
  source       = "public/index.html"
  content_type = "text/html"
  bucket       = google_storage_bucket.dont-save-her.id
}