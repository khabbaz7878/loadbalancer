variable "project_id" {}
variable "name"{}
variable "function_name" {}
variable "region" {
type = list(string) 
default=["northamerica-northeast1","us-central1"]
}