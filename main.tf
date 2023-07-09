
locals{
    cloud_functions_file_list = [for f in fileset("${path.module}/loadbalancerconfig", "[^_]*.yaml") : yamldecode(file("${path.module}/loadbalancerconfig/${f}"))]


    cloud_functions_list=flatten([
      for cloud_function in local.cloud_functions_file_list:[
        for function in try(cloud_function.mobility_cloud_functions_list,[]):{
          name  = function.name
        }
      ]
    ])

}

module "neg" {
  source = "./networkendpointgroup"
  region        = ["northamerica-northeast1","us-central1"]
  for_each={for region,function in local.cloud_functions_list: region => function}
  name=each.value.name
  project_id=var.project_id

  function_name = each.value.name

}
/*
locals {
  cloud_armor_policies = [for f in fileset("${path.module}/cloudarmorconfigs", "[^_]*.yaml") : yamldecode(file("${path.module}/cloudarmorconfigs/${f}"))]
  cloud_armor_list = flatten([
    for cloud_armor_policy in local.cloud_armor_policies : [
      for policy in try(cloud_armor_policy.central_policy, []) : {
        name               = policy.name
        project_id         = policy.project_id
        description        = try(policy.description, [])
        default_rule_action= try(policy.default_rule_action, [])  
        type               = try(policy.type, [])
        json_parsing       = try(policy.json_parsing, [])
        layer_7_ddos_defense_enable = try(policy.layer_7_ddos_defense_enable, [])
        layer_7_ddos_defense_rule_visibility = try(policy.layer_7_ddos_defense_rule_visibility, [])
        default_rule_action          = try(policy.default_rule_action,[])
        pre_configured_rules =try(policy.pre_configured_rules,[])
      }
    ]
  ])
}
module "cloud_armor" {
  source = "./modules/cloud-armor"
  for_each     = { for policy in local.cloud_armor_list : "${policy.name}-${policy.project_id}" => policy }
  project_id = each.value.project_id
  name = each.value.name
  description = each.value.description
  json_parsing = each.value.json_parsing #"STANDARD"
  #Enable Adaptive Protection
  layer_7_ddos_defense_enable = each.value.layer_7_ddos_defense_enable #true
  layer_7_ddos_defense_rule_visibility = each.value.layer_7_ddos_defense_rule_visibility #"STANDARD"

  default_rule_action          = each.value.default_rule_action #"deny(404)"
  #Add pre-configured rules















*/

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
resource "google_compute_url_map" "serverlesshttploadbalancerfrontend" {

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
