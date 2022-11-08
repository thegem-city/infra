variable "tailscale_api_key" {
  default = "your-tailscale-api-key-goes-here"
}

provider "tailscale" {
  api_key = var.tailscale_api_key
  tailnet = "your-tailnet-goes-here-it-may-be-your-email-address"
}

resource "tailscale_tailnet_key" "bastion" {
  reusable  = false
  ephemeral = false
}
