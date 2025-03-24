
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
    target_tags     = ["gke-node"]
}

#Create GKE cluster now
resource "google_container_cluster" "gke" {
    name            = "my-gke-cluster"
    location        = "us-west1-a"

    initial_node_count =1

    node_config {
        machine_type = "e2-medium"
        oauth_scopes =[
           "https://www.googleapis.com/auth/cloud-platform" 
        ]
        tags = ["gke-node"]
        metadata = {
            disable-legacy-endpints = "true"
        }
    }

    networking_mode = "VPC_NATIVE"

    subnetwork = google_compute_subnetwork.public_subnet.id 

    # Disabling protection so that we can delete after testing
    deletion_protection = false 

    #Configure private cluster but public endpoint
    private_cluster_config {
        enable_private_nodes    = true
        enable_private_endpoint  = false 
    }

    network = google_compute_network.vpc.id 
}

