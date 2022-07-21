terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }

  required_version = ">= 0.14.9"
}

# Docs on this piece
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route53_zone

data "aws_route53_zone" "selected" {
  name         = "${var.route53_domain_name}."
  private_zone = false
}

#aws_elb is only for classic load balancers
#and in AWS CLI you can only describe application load balancers using elbv2
#aws elbv2 describe-load-balancers
#terraform docshttps://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb
data "aws_lb" "web_portal" {
  name = var.load_balancer_name
  ## zone_id
  ## dns_name
}

resource "aws_route53_record" "subdomain" {
  #grabs the zone_id from the pulled route 53 zone data defined above
  zone_id = data.aws_route53_zone.selected.zone_id
  # concatenate the test subdomain name with the hosted zone with a . in between
  name = "${var.route53_subdomain_name}.${data.aws_route53_zone.selected.name}"
  type = "A"
  #don't probably need to define ttl
  # ttl     = "300"
  alias {
    #name                   = "dualstack.${var.load_balancer_dns_name}"
    name                   = "dualstack.${data.aws_lb.web_portal.dns_name}"
    zone_id                = data.aws_lb.web_portal.zone_id
    evaluate_target_health = true
  }
}

