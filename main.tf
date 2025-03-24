
# This is the provider configuration
provider "google" {
    region = "us=west1"
    project = "rare-hub-452618-j9"
}

#Create VPC
resource "google_compute_network" "vpc" {
    name = "gke-vpc"
    auto_create_subnetworks = false  #This is cause we will create custom subnets now
}


#Creating pulic subnet
resource "google_compute_subnetwork" "public_subnet" {
    name                    = "public-subnet"
    region                  = "us-west1"
    network                 = google_compute_network.vpc.id 
    ip_cidr_range           = "10.0.1.0/24"
    private_ip_google_access = true 
}

#Create private subnet
resource "google_compute_subnetwork" "private_subnet" {
    name                        = "private-subnet"
    region                      = "us-west1"
    network                     = google_compute_network.vpc.id 
    ip_cidr_range               = "10.0.2.0/24"
    private_ip_google_access    = true 
}

#Create a firewall rule to allow external access to GKe nodes
resource "google_compute_firewall" "gke_allow_inbound" {
    name        = "gke-allow-inbound"
    network     = google_compute_network.vpc.id

    allow {
        protocol    = "tcp"
        ports       = ["0-65535"]   
    }

    source_ranges   = ["0.0.0.0/0"]
    traget_tags     = ["gke-node"]
}

