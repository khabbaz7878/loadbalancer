/*resource "google_compute_global_forwarding_rule" "testport" {
  ip_address            = "34.117.32.104"
  ip_protocol           = "TCP"
  ip_version            = "IPV4"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  name                  = "testport"
  port_range            = "443-443"
  project               = "sami-islam-project101-dev"
  target                = "https://www.googleapis.com/compute/beta/projects/sami-islam-project101-dev/global/targetHttpsProxies/samiloadbalancer-target-proxy"
}*/
resource "google_compute_region_network_endpoint_group" "defaultneg1" {
  name                  = "defaultneg1"
  network_endpoint_type = "SERVERLESS"
  region                = "us-central1"
  cloud_function {
    function = "function1"
  }
  project = var.project_id
}
resource "google_compute_region_network_endpoint_group" "defaultneg2" {
  name                  = "defaultneg2"
  network_endpoint_type = "SERVERLESS"
  region                = "northamerica-northeast1"
  cloud_function {
    function = "function1"
  }
  project = var.project_id
}
resource "google_compute_region_network_endpoint_group" "negfetchdata1" {
  name                  = "negfetchdata1"
  network_endpoint_type = "SERVERLESS"
  region                = "us-central1"
  project = var.project_id
  cloud_function {
    function = "function1"
  }
}
resource "google_compute_region_network_endpoint_group" "negfetchdata2" {
  name                  = "negfetchdata2"
  network_endpoint_type = "SERVERLESS"
  region                = "northamerica-northeast1"
  cloud_function {
    function = "function2"
  }
  project = var.project_id
}
resource "google_compute_region_network_endpoint_group" "negupdatedata1" {
  name                  = "negupdatedata1"
  network_endpoint_type = "SERVERLESS"
  region                = "us-central1"
  cloud_function {
    function = "function1"
  }
  project = var.project_id
}
resource "google_compute_region_network_endpoint_group" "negupdatedata2" {
  name                  = "negupdatedata2"
  network_endpoint_type = "SERVERLESS"
  region                = "northamerica-northeast1"
  cloud_function {
    function = "function1"
  }
  project = var.project_id
}
resource "google_compute_backend_service" "defaultbackend" {
  connection_draining_timeout_sec = 0
  load_balancing_scheme           = "EXTERNAL_MANAGED"
  locality_lb_policy              = "ROUND_ROBIN"
  name                            = "defaultbackend"
  port_name                       = "http"
  project                         = "sami-islam-project101-dev"
  protocol                        = "HTTPS"
  session_affinity                = "NONE"
  timeout_sec                     = 30
    backend {
    group = google_compute_region_network_endpoint_group.defaultneg1.self_link
  }

  backend {
    group = google_compute_region_network_endpoint_group.defaultneg2.self_link
  }
}
resource "google_compute_backend_service" "backendfetchdata" {
  connection_draining_timeout_sec = 0
  load_balancing_scheme           = "EXTERNAL_MANAGED"
  locality_lb_policy              = "ROUND_ROBIN"
  name                            = "backendfetchdata"
  port_name                       = "http"
  project                         = "sami-islam-project101-dev"
  protocol                        = "HTTPS"
  session_affinity                = "NONE"
  timeout_sec                     = 30
    backend {
    group = google_compute_region_network_endpoint_group.negfetchdata1.self_link
  }

  backend {
    group = google_compute_region_network_endpoint_group.negfetchdata2.self_link
  }
}
resource "google_compute_backend_service" "backendupdatedata" {
  connection_draining_timeout_sec = 0
  load_balancing_scheme           = "EXTERNAL_MANAGED"
  locality_lb_policy              = "ROUND_ROBIN"
  name                            = "backendupdatedata"
  port_name                       = "http"
  project                         = "sami-islam-project101-dev"
  protocol                        = "HTTPS"
  session_affinity                = "NONE"
  timeout_sec                     = 30
    backend {
    group = google_compute_region_network_endpoint_group.negupdatedata1.self_link
  }

  backend {
    group = google_compute_region_network_endpoint_group.negupdatedata2.self_link
  }
}
resource "google_compute_url_map" "serverlesshttploadbalancer" {
  default_service = google_compute_backend_service.backendfetchdata.self_link
  host_rule {
    hosts        = ["srv.demoapp1.web.ca"]
    path_matcher = "path-matcher"
  }

  host_rule {
    hosts        = ["srv.demoapp1.web.ca"]
    path_matcher = "path-matcher"
  }

  name = "serverlesshttploadbalancer"

  path_matcher {
    default_service = google_compute_backend_service.defaultbackend.self_link
    name            = "path-matcher"

    path_rule {
      paths   = ["/fetchdata"]
      service = google_compute_backend_service.backendfetchdata.self_link
    }
    path_rule {
      paths   = ["/updatedata"]
      service = google_compute_backend_service.backendupdatedata.self_link
    
    }
/*  }

  path_matcher {
    default_service = google_compute_backend_service.backendupdatedata.self_link
    name            = "path-matcher-updatedata"

    }*/
  }
  

  project = "sami-islam-project101-dev"
}


resource "google_compute_managed_ssl_certificate" "default" {
  provider = google-beta
  project  = var.project_id
  name     = "samiislammanagedcertificate"

  lifecycle {
    create_before_destroy = true
  }

  managed {
    domains = var.managed_ssl_certificate_domains
  }
}
