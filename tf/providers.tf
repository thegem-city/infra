terraform {
  required_version = "= 1.3.3"
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "= 4.22.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "= 3.1.1"
    }
    local = {
      source  = "hashicorp/local"
      version = "= 2.2.3"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "= 3.4.0"
    }
    tailscale = {
      source  = "tailscale/tailscale"
      version = "= 0.13.5"
    }
    acme = {
      source  = "vancluever/acme"
      version = "= 2.11.1"
    }
  }
}
