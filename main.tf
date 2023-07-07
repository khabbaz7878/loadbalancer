resource "google_compute_global_forwarding_rule" "testport" {
  ip_address            = "34.117.32.104"
  ip_protocol           = "TCP"
  ip_version            = "IPV4"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  name                  = "testport"
  port_range            = "443-443"
  project               = "sami-islam-project101-dev"
  target                = "https://www.googleapis.com/compute/beta/projects/sami-islam-project101-dev/global/targetHttpsProxies/samiloadbalancer-target-proxy"
}
resource "google_compute_region_network_endpoint_group" "neg1" {
  name                  = "neg1"
  network_endpoint_type = "SERVERLESS"
  region                = "us-central1"
  cloud_function {
    function = "function1"
  }
}
resource "google_compute_region_network_endpoint_group" "neg2" {
  name                  = "neg2"
  network_endpoint_type = "SERVERLESS"
  region                = "northamerica-northeast1"
  cloud_function {
    function = "function2"
  }
}

resource "google_compute_backend_service" "backend_fetchData" {
  connection_draining_timeout_sec = 0
  load_balancing_scheme           = "EXTERNAL_MANAGED"
  locality_lb_policy              = "ROUND_ROBIN"
  name                            = "bestbackend"
  port_name                       = "http"
  project                         = "sami-islam-project101-dev"
  protocol                        = "HTTPS"
  session_affinity                = "NONE"
  timeout_sec                     = 30

    backend {
    group = google_compute_region_network_endpoint_group.neg1.self_link
  }

  backend {
    group = google_compute_region_network_endpoint_group.neg2.self_link
  }
}
resource "google_compute_url_map" "samiloadbalancer" {
  default_service = google_compute_backend_service.backend_fetchData.self_link

  host_rule {
    hosts        = ["srv.demoapp1.web.ca"]
    path_matcher = "path-matcher-2"
  }

  host_rule {
    hosts        = ["samiislam.com"]
    path_matcher = "path-matcher-1"
  }

  name = "samiloadbalancer"

  path_matcher {
    default_service = "https://www.googleapis.com/compute/v1/projects/sami-islam-project101-dev/global/backendServices/bestbackend"
    name            = "path-matcher-1"

    path_rule {
      paths   = ["/tr7ty9s"]
      service = "https://www.googleapis.com/compute/v1/projects/sami-islam-project101-dev/global/backendServices/bestbackend"
    }
  }

  path_matcher {
    default_service = "https://www.googleapis.com/compute/v1/projects/sami-islam-project101-dev/global/backendServices/bestbackend"
    name            = "path-matcher-2"

    path_rule {
      paths   = ["/1l2134m2214"]
      service = "https://www.googleapis.com/compute/v1/projects/sami-islam-project101-dev/global/backendServices/bestbackend"
    }
  }

  project = "sami-islam-project101-dev"
}

resource "google_compute_ssl_certificate" "newcertificate" {
  project = var.project_id
  certificate = var.certificate
  private_key = var.private_key
}
