data "aws_subnets" "dc_apps_a" {
  filter {
    name   = "cidr-block"
    values = [local.vpc_subnets_dc_apps[0], local.vpc_subnets_dc_apps[1], local.vpc_subnets_dc_apps[2]]
  }
  filter {
    name   = "availability-zone"
    values = ["us-east-2a"]
  }
}

data "aws_subnets" "dc_apps_b" {
  filter {
    name   = "cidr-block"
    values = [local.vpc_subnets_dc_apps[0], local.vpc_subnets_dc_apps[1], local.vpc_subnets_dc_apps[2]]
  }
  filter {
    name   = "availability-zone"
    values = ["us-east-2b"]
  }
}

data "aws_subnets" "dc_apps_c" {
  filter {
    name   = "cidr-block"
    values = [local.vpc_subnets_dc_apps[0], local.vpc_subnets_dc_apps[1], local.vpc_subnets_dc_apps[2]]
  }
  filter {
    name   = "availability-zone"
    values = ["us-east-2c"]
  }
}

data "aws_subnets" "external" {
  filter {
    name   = "cidr-block"
    values = local.vpc_subnets_dc_external
  }
  filter {
    name   = "availability-zone"
    values = ["us-east-2a", "us-east-2b", "us-east-2c"]
  }
}

resource "aws_security_group" "mastodon" {
  name   = "mastodon"
  vpc_id = module.vpc.vpc_id

  ingress {
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = [var.vpc_cidr]
  }

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "mastodon-a" {
  ami                         = "ami-03ba6c40a876f6ed6"
  key_name                    = aws_key_pair.primary.key_name
  instance_type               = "t2.medium"
  subnet_id                   = data.aws_subnets.dc_apps_a.ids[0]
  vpc_security_group_ids      = ["${aws_security_group.mastodon.id}"]
  associate_public_ip_address = false
  availability_zone           = "us-east-2a"

  root_block_device {
    volume_size = 100
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_target_group_attachment" "mastodon-a-external" {
  target_group_arn = aws_lb_target_group.mastodon.arn
  target_id        = aws_instance.mastodon-a.id
  port             = 80
}

resource "aws_route53_record" "mastodon-a" {
  zone_id = aws_route53_zone.thegem-city.zone_id
  name    = "mastodon-a."
  type    = "A"
  ttl     = 300
  records = [aws_instance.mastodon-a.private_ip]
}
