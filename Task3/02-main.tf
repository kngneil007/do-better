# create a europe vpc network
resource "google_compute_network" "eu-vpc" {
  name                    = var.eu-vpc.vpc.name
  auto_create_subnetworks = false
}

# create a eu subnet
resource "google_compute_subnetwork" "eu-subnet" {
  name                     = var.eu-vpc.eu-subnet.name
  ip_cidr_range            = var.eu-vpc.eu-subnet.cidr
  region                   = var.eu-vpc.eu-subnet.region
  network                  = google_compute_network.eu-vpc.id
  private_ip_google_access = true
}

# create a firewall to allow http traffic in europe
# resource "google_compute_firewall" "eu-firewall" {
#   name    = var.eu-vpc.vpc.firewall
#   network = google_compute_network.eu-vpc.id

#   allow {
#     protocol = "tcp"
#     ports    = var.ports
#   }

#   target_tags = ["eu-http-server"]
#   # open htt-server to the world


#   # source_ranges = [var.eu-vpc.eu-subnet.cidr, var.us-vpc.us-east-subnet.cidr,
#   # var.us-vpc.us-west-subnet.cidr, var.asia-vpc.asia-subnet.cidr, "35.235.240.0/20"]
#   source_ranges = ["0.0.0.0/0"]
# }

resource "google_compute_firewall" "eu-firewall" {
  name    = var.eu-vpc.vpc.firewall
  network = google_compute_network.eu-vpc.id

  allow {
    protocol = "tcp"
    ports    = var.ports
  }

  allow {
    protocol = "icmp"
  }

  # source_ranges = ["0.0.0.0/0"]
  source_ranges = [var.eu-vpc.eu-subnet.cidr, var.us-vpc.us-east-subnet.cidr,
  var.us-west-vpc.us-west-subnet.cidr, var.asia-vpc.asia-subnet.cidr]
  priority = 1000
}


resource "google_compute_instance" "eu-instance" {
  name         = var.eu-vpc.eu-subnet.instance-name
  machine_type = var.machine_types.linux.machine_type
  zone         = var.eu-vpc.eu-subnet.zone


  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
      size  = 10
    }
    # true by default
    auto_delete = true
  }

  network_interface {
    network    = var.eu-vpc.vpc.name
    subnetwork = var.eu-vpc.eu-subnet.name

    # No External IP
    # access_config {
    #   // Ephemeral public IP
    # }
  }

  tags = ["http-server"]

  # metadata = {
  #   startup-script-url = "${file("startup.sh")}"
  # }

  metadata_startup_script = file("startup.sh")

  depends_on = [google_compute_network.eu-vpc,
  google_compute_subnetwork.eu-subnet, google_compute_firewall.eu-firewall]
}


#-----------------Asia-------


# create asia vpc network
resource "google_compute_network" "asia-vpc" {
  name                    = var.asia-vpc.vpc.name
  auto_create_subnetworks = false
}

# create an asia subnet
resource "google_compute_subnetwork" "asia-subnet" {
  name                     = var.asia-vpc.asia-subnet.name
  ip_cidr_range            = var.asia-vpc.asia-subnet.cidr
  region                   = var.asia-vpc.asia-subnet.region
  network                  = google_compute_network.asia-vpc.id
  private_ip_google_access = true
}

# create a firewall for asia RDP
resource "google_compute_firewall" "asia-allow-rdp" {
  project = var.project_id
  name    = var.asia-vpc.vpc.firewall
  network = google_compute_network.asia-vpc.id

  allow {
    protocol = "tcp"
    ports    = 3389
  }

  # direction = "EGRESS"

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["asia-rdp-server"]
}

# resource "google_compute_firewall" "asia" {
#   project = var.project_id
#   name    = "allow-remote"
#   network = google_compute_network.asia-vpc.id

#   # allow {
#   #   protocol = "tcp"
#   #   ports    = var.ports[1]
#   # }
#   # direction     = "EGRESS"
#   # source_ranges = var.source_ranges

#   allow {
#     protocol = "icmp"
#   }

#   allow {
#     protocol = "tcp"
#     ports    = var.ports
#   }

#   source_ranges = ["0.0.0.0/0"]
# }

# create an asia instance windows machine
resource "google_compute_instance" "asia-instance" {
  name         = var.asia-vpc.asia-subnet.instance-name
  machine_type = var.machine_types.windows.machine_type
  zone         = var.asia-vpc.asia-subnet.zone

  boot_disk {
    initialize_params {
      image = var.machine_types.windows.image
      size  = tonumber(var.machine_types.windows.size)
    }
    auto_delete = true
  }

  network_interface {
    network    = google_compute_network.asia-vpc.id
    subnetwork = google_compute_subnetwork.asia-subnet.id

    # External IP
    access_config {
      // Ephemeral public IP
    }
  }

  tags = ["asia-rdp-server"]
}

# ------------------ US  east -----------

# create a us vpc network
resource "google_compute_network" "us-vpc" {
  name                    = var.us-vpc.vpc.name
  auto_create_subnetworks = false
}

# create an us-east subnet
resource "google_compute_subnetwork" "us-east-subnet" {
  name                     = var.us-vpc.us-east-subnet.name
  ip_cidr_range            = var.us-vpc.us-east-subnet.cidr
  region                   = var.us-vpc.us-east-subnet.region
  network                  = google_compute_network.us-vpc.id
  private_ip_google_access = true
}

# create a firewall to allow http from us to europe
resource "google_compute_firewall" "us-firewall" {
  name    = var.us-vpc.vpc.firewall
  network = google_compute_network.us-vpc.id

  allow {
    protocol = "tcp"
    ports    = ["22", "80"]
  }

  # direction = "EGRESS"

  target_tags   = ["us-http-server", "iap-ssh-allowed"]
  source_ranges = ["0.0.0.0/0", "35.235.240.0/20"]
}

# create a us-east instance
resource "google_compute_instance" "us-east-instance" {
  depends_on = [google_compute_network.us-vpc, google_compute_subnetwork.us-east-subnet]

  name         = var.us-vpc.us-east-subnet.instance-name
  machine_type = var.machine_types.linux.machine_type
  zone         = var.us-vpc.us-east-subnet.zone

  boot_disk {
    initialize_params {
      image = var.machine_types.linux.image
      size  = tonumber(var.machine_types.linux.size)
    }
    auto_delete = true
  }

  network_interface {
    network    = var.us-vpc.vpc.name
    subnetwork = var.us-vpc.us-east-subnet.name

    # access_config {
    #   // Ephemeral public IP
    # }
  }

  tags = ["us-http-server", "iap-ssh-allowed"]
  # no script needed for this instance
  # metadata_startup_script = file("startup.sh")

}

# ----------------- US west -----------

# create a us west vpc network
resource "google_compute_network" "us-west-vpc" {
  name                    = var.us-west-vpc.vpc.name
  auto_create_subnetworks = false
}

# create an us-west subnet
resource "google_compute_subnetwork" "us-west-subnet" {
  name                     = var.us-west-vpc.us-west-subnet.name
  ip_cidr_range            = var.us-west-vpc.us-west-subnet.cidr
  region                   = var.us-west-vpc.us-west-subnet.region
  network                  = google_compute_network.us-west-vpc.id
  private_ip_google_access = true
}

# create a firewall to allow http from us-west to europe
resource "google_compute_firewall" "us-west-firewall" {
  name    = var.us-west-vpc.vpc.firewall
  network = google_compute_network.us-west-vpc.id

  allow {
    protocol = "tcp"
    ports    = ["22", "80"]
  }

  # direction = "EGRESS"

  target_tags   = ["us-west-http-server", "iap-ssh-allowed"]
  source_ranges = ["0.0.0.0/0", "35.235.240.0/20"]
}

# create a us-west instance
resource "google_compute_instance" "us-west-instance" {
  name         = var.us-west-vpc.us-west-subnet.instance-name
  machine_type = var.machine_types.linux.machine_type
  zone         = var.us-west-vpc.us-west-subnet.zone

  boot_disk {
    initialize_params {
      image = var.machine_types.linux.image
      size  = tonumber(var.machine_types.linux.size)
    }
    auto_delete = true
  }

  network_interface {
    network    = var.us-west-vpc.vpc.name
    subnetwork = var.us-west-vpc.us-west-subnet.name

    # access_config {
    #   // Ephemeral public IP
    # }
  }

  tags = ["us-http-server", "iap-ssh-allowed"]
  # no script needed for this instance
  # metadata_startup_script = file("startup.sh")

}

# -------------------------  peering -------------------------

# VPC Peering from us to eu
resource "google_compute_network_peering" "us-to-eu" {
  name         = "us-to-eu"
  network      = google_compute_network.us-vpc.id
  peer_network = google_compute_network.eu-vpc.id
}

# VPC Peering from eu to us
resource "google_compute_network_peering" "eu-to-us" {
  name         = "eu-to-us"
  network      = google_compute_network.eu-vpc.id
  peer_network = google_compute_network.us-vpc.id
}

# VPC Peering from us west to eu
resource "google_compute_network_peering" "uswest-to-eu" {
  name         = "uswest-to-eu"
  network      = google_compute_network.us-west-vpc.id
  peer_network = google_compute_network.eu-vpc.id
}

# VPC Peering from eu to us west
resource "google_compute_network_peering" "eu-to-uswest" {
  name         = "eu-to-uswest"
  network      = google_compute_network.eu-vpc.id
  peer_network = google_compute_network.us-west-vpc.id
}

# --------------   VPN -----------   

# eu vpn gateway
resource "google_compute_vpn_gateway" "eu-vpn-gw" {
  name    = "eu-vpn-gw"
  network = google_compute_network.eu-vpc.id
  region  = var.eu-vpc.eu-subnet.region
}

# asia vpn gateway
resource "google_compute_vpn_gateway" "asia-vpn-gw" {
  name    = "asia-vpn-gw"
  network = google_compute_network.asia-vpc.id
  region  = var.asia-vpc.asia-subnet.region
}

# external IP for eu vpn gateway
resource "google_compute_address" "eu-vpn-ip" {
  name   = "eu-vpn-ipv4"
  region = var.eu-vpc.eu-subnet.region
}

# external IP for asia vpn gateway
resource "google_compute_address" "asia-vpn-ip" {
  name   = "asia-vpn-ipv4"
  region = var.asia-vpc.asia-subnet.region
}

# google secret manager secret
data "google_secret_manager_secret_version" "vpn-shared-secret" {
  secret  = "here a secret key needs to be created. Vpn will not work without one"
  version = "latest"
}

# vpn tunnel from asia to eu
resource "google_compute_vpn_tunnel" "asia-to-eu" {
  name          = "asia-to-eu"
  region        = var.asia-vpc.asia-subnet.region
  peer_ip       = google_compute_address.eu-vpn-ip.address
  shared_secret = data.google_secret_manager_secret_version.vpn-shared-secret.secret_data
  ike_version   = 2

  # target vpn is current vpn gateway
  target_vpn_gateway = google_compute_vpn_gateway.asia-vpn-gw.id

  local_traffic_selector  = [var.asia-vpc.asia-subnet.cidr]
  remote_traffic_selector = [var.eu-vpc.eu-subnet.cidr]

  # depends on forwarding rules
  depends_on = [google_compute_forwarding_rule.asia-esp,
    google_compute_forwarding_rule.asia-udp-500,
  google_compute_forwarding_rule.asia-udp-4500]
}

# route for asia to eu
resource "google_compute_route" "asia-to-eu" {
  depends_on          = [google_compute_vpn_tunnel.asia-to-eu]
  name                = "asia-to-eu"
  network             = google_compute_network.asia-vpc.id
  dest_range          = var.eu-vpc.eu-subnet.cidr
  next_hop_vpn_tunnel = google_compute_vpn_tunnel.asia-to-eu.id
  priority            = 1000
}

# asia to eu forwarding rule asia-esp
resource "google_compute_forwarding_rule" "asia-esp" {
  name        = "asia-esp"
  ip_protocol = "ESP"
  region      = var.asia-vpc.asia-subnet.region
  ip_address  = google_compute_address.asia-vpn-ip.address
  # asia gateway target
  target = google_compute_vpn_gateway.asia-vpn-gw.id
}

# asia to eu forwarding rule asia-udp-500
resource "google_compute_forwarding_rule" "asia-udp-500" {
  name        = "asia-udp-500"
  ip_protocol = "UDP"
  port_range  = "500"
  region      = var.asia-vpc.asia-subnet.region
  ip_address  = google_compute_address.asia-vpn-ip.address
  target      = google_compute_vpn_gateway.asia-vpn-gw.id
}

# asia to eu forwarding rule asia-udp-4500
resource "google_compute_forwarding_rule" "asia-udp-4500" {
  name        = "asia-udp-4500"
  ip_protocol = "UDP"
  port_range  = "4500"
  region      = var.asia-vpc.asia-subnet.region
  ip_address  = google_compute_address.asia-vpn-ip.address
  target      = google_compute_vpn_gateway.asia-vpn-gw.id
}

# vpn tunnel from eu to asia
resource "google_compute_vpn_tunnel" "eu-to-asia" {
  name          = "eu-to-asia"
  region        = var.eu-vpc.eu-subnet.region
  peer_ip       = google_compute_address.asia-vpn-ip.address
  shared_secret = data.google_secret_manager_secret_version.vpn-shared-secret.secret_data
  ike_version   = 2

  target_vpn_gateway = google_compute_vpn_gateway.eu-vpn-gw.id

  local_traffic_selector  = [var.eu-vpc.eu-subnet.cidr]
  remote_traffic_selector = [var.asia-vpc.asia-subnet.cidr]

  # depends on forwarding rules
  depends_on = [google_compute_forwarding_rule.eu-esp,
    google_compute_forwarding_rule.eu-udp-500,
  google_compute_forwarding_rule.eu-udp-4500]
}

# route for eu to asia
resource "google_compute_route" "eu-to-asia" {
  depends_on          = [google_compute_vpn_tunnel.asia-to-eu]
  name                = "eu-to-asia"
  network             = google_compute_network.eu-vpc.id
  dest_range          = var.asia-vpc.asia-subnet.cidr
  next_hop_vpn_tunnel = google_compute_vpn_tunnel.eu-to-asia.id
  priority            = 1000
}

# forwarding rule eu-esp
resource "google_compute_forwarding_rule" "eu-esp" {
  name        = "eu-esp"
  ip_protocol = "ESP"
  region      = var.eu-vpc.eu-subnet.region
  ip_address  = google_compute_address.eu-vpn-ip.address
  target      = google_compute_vpn_gateway.eu-vpn-gw.id
}

# forwarding rule eu-udp-500
resource "google_compute_forwarding_rule" "eu-udp-500" {
  name        = "eu-udp-500"
  ip_protocol = "UDP"
  port_range  = "500"
  region      = var.eu-vpc.eu-subnet.region
  ip_address  = google_compute_address.eu-vpn-ip.address
  target      = google_compute_vpn_gateway.eu-vpn-gw.id
}

# forwarding rule eu-udp-4500
resource "google_compute_forwarding_rule" "eu-udp-4500" {
  name        = "eu-udp-4500"
  ip_protocol = "UDP"
  port_range  = "4500"
  region      = var.eu-vpc.eu-subnet.region
  ip_address  = google_compute_address.eu-vpn-ip.address
  target      = google_compute_vpn_gateway.eu-vpn-gw.id
}



