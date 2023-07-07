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

resource "google_compute_url_map" "samiloadbalancer" {
  default_service = "https://www.googleapis.com/compute/v1/projects/sami-islam-project101-dev/global/backendServices/bestbackend"

  host_rule {
    hosts        = ["saksdslca"]
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
resource "google_compute_backend_service" "bestbackend" {
  connection_draining_timeout_sec = 0
  load_balancing_scheme           = "EXTERNAL_MANAGED"
  locality_lb_policy              = "ROUND_ROBIN"
  name                            = "bestbackend"
  port_name                       = "http"
  project                         = "sami-islam-project101-dev"
  protocol                        = "HTTPS"
  session_affinity                = "NONE"
  timeout_sec                     = 30
}
