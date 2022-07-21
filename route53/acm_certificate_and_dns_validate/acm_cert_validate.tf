terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }

  required_version = ">= 0.14.9"
}

#generate the new certificate
#use DNS, not email validation
resource "aws_acm_certificate" "subdomain" {
  domain_name       = "${var.route53_subdomain_name}.${var.route53_domain_name}"
  validation_method = "DNS"
}

# Grab the information about the subdomain that was already created from the zone
# it should be zone instead of record because record is not supported as a data source
data "aws_route53_zone" "domain" {
  name       = "${var.route53_domain_name}"
}

# This is closely based on the example from the provider docs
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate_validation
resource "aws_route53_record" "certificate_dns" {
# Go get the newly generated acm certificate domain validation information
# Use a for loop to get the ACM validation CNAMEs and store them in variables
  for_each = {
    for dvo in aws_acm_certificate.subdomain.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

# Generate a CNAME DNS entry for a domain with the same FQDN as the new certificate
  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.domain.zone_id
}


# Validate that the new DNS validation record is correct
resource "aws_acm_certificate_validation" "newcert" {
  certificate_arn         = aws_acm_certificate.subdomain.arn
  #Should only be creating on FQDN for this case
  #validation_record_fqdns = ["${var.route53_subdomain_name}.${var.route53_domain_name}"]
  #This is rough the structure for multiple names by going  into the new subdomain's record and 
  #validating each FQDN that was created
  validation_record_fqdns = [for record in aws_route53_record.certificate_dns : record.fqdn]
}

output "new_acm_certificate_arn" {
  value = aws_acm_certificate_validation.newcert.certificate_arn
}