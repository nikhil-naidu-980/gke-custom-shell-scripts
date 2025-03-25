
# This is the provider configuration
provider "google" {
    region = "us=west1"
    project = "rare-hub-452618-j9"
}

data "google_client_config" "default" {}

provider "kubernetes" {
    host                    = "https://${google_container_cluster.gke.endpoint}"
    cluster_ca_certificate  = base64decode(google_container_cluster.gke.master_auth[0].cluster_ca_certificate)
    token                   = data.google_client_config.access_token
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

# IAM Role for GKE cluster
resource "google_service_account" "gke_service_account" {
    account_id          = "gke-service-account"
    display_name        = "GKE Service Account"
}

# IAM role attachment for GKE SA
resource "google_project_iam_member" "gke_service_account_role" {
    project             = "rare-hub-452618-j9"
    role                = "roles/container.clusterAdmin"
    member              = "serviceAccount:${google_service_account.gke_service_account.email}"
}

resource "google_project_iam_member" "gke_node_role" {
    project             = "rare-hub-452618-j9"
    role                = "roles/compute.instanceAdmin"
    member              = "serviceAccount:${google_service_account.gke_service_account.email}"
}

resource "google_project_iam_member" "gke_node_pull_images" {
    project             = "rare-hub-452618-j9"
    role                = "roles/storage.objectViewer"
    member              = "serviceAccount:${google_service_account.gke_service_account.email}"
}

resource "google_project_iam_member" "gke_service_account_artifact_registry" {
    project             = "rare-hub-452618-j9"
    role                = "roles/artifactregistry.reader"
    member              = "serviceAccount:${google_service_account.gke_service_account.email}"
}

# Create Node pool
resource "google_container_node_pool" "node_pool" {
    name                = "default-node-pool"
    location            = "us-west1-a"
    cluster             = google_container_cluster.gke.name 
    node_count          = 1

    node_config {
        machine_type    = "e2-medium"
        oauth_scopes = [
            "https://www.googleapis.com/auth/cloud-platform"
        ]

        tags            = ["gke-node"]
        service_account = google_service_account.gke_service_account.email 
    }
}




