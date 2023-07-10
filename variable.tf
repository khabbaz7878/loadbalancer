variable "host"{
    type = string
}
variable "project_id" {
    type=string
  
}
variable "certificate" {
  description = "Content of the SSL certificate. Required if `ssl` is `true` and `ssl_certificates` is empty."
  type        = string
  default     = null
}
variable "private_key" {
  description = "Content of the private SSL key. Required if `ssl` is `true` and `ssl_certificates` is empty."
  type        = string
  default     = null
}
variable "managed_ssl_certificate_domains"{
  description = "Create Google-managed SSL certificates for specified domains. Requires `ssl` to be set to `true` and `use_ssl_certificates` set to `false`."
  type        = list(string)
  default     = []
}

variable "region" {
type = list(string) 
}