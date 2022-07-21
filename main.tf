terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }

  required_version = ">= 0.14.9"
}

provider "aws" {
  profile = "default"
  #Region not needed for Route 53, which is global
  region = var.region_id
}

# Create the new subdomain DNS record
module "new-route53-domain-record" {
  source                 = "./route53/new-route53-domain-record"
  route53_subdomain_name = var.route53_subdomain_name
  route53_domain_name    = var.route53_domain_name
  load_balancer_name     = var.load_balancer_name
}

# Generate and validate new ACM certificate for subdomain
module "acm_certificate_and_dns_validate" {
  source                 = "./route53/acm_certificate_and_dns_validate"
  route53_subdomain_name = var.route53_subdomain_name
  route53_domain_name    = var.route53_domain_name
  #outputs new_listener_arn
  #outputs new_acm_certificate_arn
}

# Get the data about the selected load balancer
data "aws_lb" "existing_balancer" {
  name         = var.load_balancer_name
}

# Get data about the listener from the existing load balancer
data "aws_lb_listener" "existing_listener" {
  load_balancer_arn = data.aws_lb.existing_balancer.arn
  port              = "443"
}

# Attach newly generated certificate to existing load balancer
# using outputs from acm_certificate_and_dns_validate module
resource "aws_lb_listener_certificate" "alb_cert" {
  listener_arn    = data.aws_lb_listener.existing_listener.arn
  certificate_arn = module.acm_certificate_and_dns_validate.new_acm_certificate_arn

  #certificate_arn = aws_acm_certificate.example.arn
  #I think it would be like....
  #listener_arn    = module.acm_certificate_and_dns_validate.new_listener_arn.front_end.arn
  #certificate_arn = module.acm_certificate_and_dns_validate.new_acm_certificate_arn.arn

}