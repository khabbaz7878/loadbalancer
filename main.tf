locals{
    cloud_functions_file_list = [for f in fileset("${path.module}/loadbalancerconfig", "[^_]*.yaml") : yamldecode(file("${path.module}/loadbalancerconfig/${f}"))]


    cloud_functions_list=flatten([
      for cloud_function in local.cloud_functions_file_list:[
        for function in try(cloud_function.mobility_cloud_functions_list,[]):{
          neg_name  = lower(function.name)
          name=function.name
        }
      ]
    ])

}

module "neg" {
  source = "./networkendpointgroup"
  region        = ["northamerica-northeast1","us-central1"]
  for_each={for region,function in local.cloud_functions_list: region => function}
  name="neg-${each.value.neg_name}"
  project_id=var.project_id
  function_name = each.value.name
}

resource "google_compute_backend_service" "mobilitybackendservice" {
  for_each                        = { for index, instance in module.neg : index => {
    neg_self_link_us_central = instance.neg_self_link_us_central
    neg_self_link_north_america = instance.neg_self_link_north_america
    function_name = lower(instance.function_name)
  } }
  connection_draining_timeout_sec = 0
  load_balancing_scheme           = "EXTERNAL_MANAGED"
  locality_lb_policy              = "ROUND_ROBIN"
  name                            = "backend-${each.value.function_name}"
  port_name                       = "http"
  project                         = "sami-islam-project101-dev"
  protocol                        = "HTTPS"
  session_affinity                = "NONE"
  timeout_sec                     = 30
  backend {
    group = each.value.neg_self_link_us_central
  }

  backend {
    group = each.value.neg_self_link_north_america
  }
}

resource "google_compute_url_map" "serverlesshttploadbalancerfrontend" {

  default_service = google_compute_backend_service.mobilitybackendservice[0].self_link
  host_rule {
    hosts        = ["srv.demoapp1.web.ca"]
    path_matcher = "path-matcher"
  }

  name = "serverlesshttploadbalancer"

  path_matcher {
  default_service = google_compute_backend_service.mobilitybackendservice[0].self_link
    name            = "path-matcher"
    dynamic "path_rule" {
      for_each = google_compute_backend_service.mobilitybackendservice
      content {
        paths   = [ format("/%s", split("-", path_rule.value["name"])[1])]
        service = path_rule.value["self_link"]
      }

    }
  }
  project = "sami-islam-project101-dev"
}
resource "google_compute_global_forwarding_rule" "frontend" {
  ip_protocol           = "TCP"
  ip_version            = "IPV4"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  name                  = "frontend"
  port_range            = "443-443"
  project               = "sami-islam-project101-dev"
  target                = "https://www.googleapis.com/compute/beta/projects/sami-islam-project101-dev/global/targetHttpsProxies/aw-target-proxy"
}
/*resource "google_compute_global_forwarding_rule" "frontendhttps" {
  provider              = google-beta
  project               = var.project
  ip_protocol           = "HTTPS"
  ip_version            = "IPV4"
  name                  = "mobility-loadbalancer-https"
  target                = google_compute_target_https_proxy.default[0].self_link
  port_range            = "443-443"
  load_balancing_scheme = "EXTERNAL_MANAGED"
}
*/
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
