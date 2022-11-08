# infra

Infrastructure configuration and documentation for https://thegem.city/

# Incomplete

I also host https://help.thegem.city/, https://matrix.thegem.city/, and https://whatthecommit.com/, but the infrastructure configuration for those resources is not included.

# Usage

First init:

    $ terraform init

Then plan to review:

    $ terraform plan

Then apply:

    $ terraform apply

## Order

If you were setting this up from scratch with a newly minted domain, the first thing you'd do is selectively create the DNS zone and update the NS records of your domain to point to route53 with your provider.

    $ terraform apply -target=aws_route53_zone.thegem-city

Then once the nameserver changes are picked up and globally resolve, proceed to apply the rest of the configuration.

## Let's Encrypt

This uses DNS challanges to get a wildcard SSL certificate that can then be used by the AWS load balancer. The DNS certificate will need to be refreshed every 90 days with this method.

