resource "tls_private_key" "primary" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "primary" {
  key_name   = "the-gem-city-primary"
  public_key = tls_private_key.primary.public_key_openssh
}

# output "ssh_key" {
#   value     = tls_private_key.primary.private_key_pem
#   sensitive = true
# }
