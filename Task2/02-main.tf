# <!-- ### Message to the Last Person on Earth

# ---

# To the Last Survivor,

# Your mission is critical. You must store essential information on the cloud to ensure that any future survivors can access it. Follow these instructions carefully to create a publicly accessible bucket in Google Cloud Platform (GCP) using Terraform. This bucket will hold vital data that could be the key to survival for those who come after you.

# #### Objective:

# Create a publicly accessible bucket in GCP using Terraform, designed to store vital information.

# #### Tasks to Complete:

# 1. **Terraform Script:**
#    - Write a Terraform script to create the GCP bucket.

# 2. **GitHub Push:**
#    - Push the Terraform script to your GitHub repository for safekeeping and accessibility.

# 3. **Output Public Link:**
#    - Ensure the Terraform script outputs the public link to the bucket.

# 4. **Index.html File:**
#    - Include an `index.html` file within the bucket containing survival instructions.

# #### Problem Statement:

# You need to create a GCP bucket that meets the following requirements:
# - Use a Terraform script to create the bucket.
# - Push the script to GitHub for version control and accessibility.
# - Ensure the public link to the bucket is available and displayed in the output.
# - The bucket must contain an `index.html` file as the default page with essential survival instructions.

# #### Example:

# The final setup should provide a public link to an HTML page stored within the bucket.

# #### Data Required:

# - **Bucket Resource:** The definition and configuration of the GCP bucket.
# - **index.html File:** The HTML file with survival instructions to be stored within the bucket.
# - **Public Access:** Settings to make the bucket publicly accessible.

# #### Algorithm:

# 1. **Define Bucket Resource:**
#    - Use Terraform to define and create the GCP bucket.

# 2. **Configure Public Access:**
#    - Set the necessary permissions to make the bucket public.

# 3. **Upload index.html:**
#    - Ensure the `index.html` file is uploaded to the bucket.

# 4. **Output Public URL:**
#    - Configure the output to display the public link to the bucket.

# ---

# Follow these steps precisely. The future of humanity may depend on it.

# Good luck.


resource "google_compute_instance" "task2" {
  name         = var.instance_name
  machine_type = var.machine_type
  zone         = var.zone


  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
      size  = 10
    }
    # true by default
    auto_delete = true
  }

  network_interface {
    network    = var.network_name
    subnetwork = var.subnet_name

    access_config {
      // Ephemeral public IP
    }
  }

  tags = ["http-server"]

  # metadata = {
  #   startup-script-url = "${file("startup.sh")}"
  # }

  metadata_startup_script = file("startup.sh")

  depends_on = [google_compute_network.task2_vpc,
  google_compute_subnetwork.task2_subnet, google_compute_firewall.rules]
}

resource "google_storage_bucket" "task2" {
  name          = "${var.project_id}-task2"
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
  # uniform_bucket_level_access = false
}
# Create a Google VPC 
resource "google_compute_network" "task2_vpc" {
  project                 = var.project_id
  name                    = var.network_name
  auto_create_subnetworks = false
  mtu                     = 1460
}

# add subnet to the VPC
resource "google_compute_subnetwork" "task2_subnet" {
  name          = var.subnet_name
  ip_cidr_range = var.ip_cidr_range
  region        = var.region
  network       = google_compute_network.task2_vpc.id
}

# firewall rule to allow traffic on port 80
resource "google_compute_firewall" "rules" {
  name    = var.firewall_name
  network = google_compute_network.task2_vpc.id

  allow {
    protocol = "tcp"
    ports    = var.ports
  }

  allow {
    protocol = "icmp"
  }

  source_ranges = var.source_ranges
  priority      = 1000
}