locals {
  tailscale_adv_routes = join(",", concat(local.vpc_subnets_dc_external, local.vpc_subnets_dc_apps))
}

resource "aws_security_group" "bastion" {
  name   = "bastion"
  vpc_id = module.vpc.vpc_id

  ingress {
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "bastion" {
  ami                         = "ami-03ba6c40a876f6ed6"
  key_name                    = aws_key_pair.primary.key_name
  instance_type               = "t2.micro"
  subnet_id                   = module.vpc.public_subnets[0]
  vpc_security_group_ids      = ["${aws_security_group.bastion.id}"]
  associate_public_ip_address = true

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [tags]
  }

  provisioner "remote-exec" {
    inline = [
      "curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/jammy.noarmor.gpg | sudo tee /usr/share/keyrings/tailscale-archive-keyring.gpg > /dev/null",
      "curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/jammy.tailscale-keyring.list | sudo tee /etc/apt/sources.list.d/tailscale.list",
      "sudo apt update -qq",
      "sudo apt install -y tailscale",
      "sudo systemctl enable --now tailscaled",
      "echo 'net.ipv4.ip_forward = 1' | sudo tee -a /etc/sysctl.conf",
      "sudo sysctl -p /etc/sysctl.conf",
      "sudo tailscale up --hostname=bastion --authkey=${tailscale_tailnet_key.bastion.key} --advertise-routes=${local.tailscale_adv_routes}",
      "tailscale ip -4"
    ]
  }

  connection {
    type        = "ssh"
    host        = self.public_ip
    user        = "ubuntu"
    private_key = tls_private_key.primary.private_key_pem
  }
}

resource "aws_route53_record" "bastion" {
  zone_id = aws_route53_zone.thegem-city.zone_id
  name    = "bastion."
  type    = "A"
  ttl     = 300
  records = [aws_instance.bastion.public_ip]
}
