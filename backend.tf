terraform {
 cloud {
    organization = "sami600"
    
    workspaces { 
      tags = ["loadbalancer"]
    }
  }
}