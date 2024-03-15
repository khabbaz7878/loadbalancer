terraform {
 cloud {
    organization = "khabbaz7878"
    
    workspaces { 
      tags = ["loadbalancer"]
    }
  }
}
