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

module "new-route53-domain-record" {
  source                 = "./route53/new-route53-domain-record"
  route53_subdomain_name = var.route53_subdomain_name
  route53_domain_name    = var.route53_domain_name
  load_balancer_name     = var.load_balancer_name
}

