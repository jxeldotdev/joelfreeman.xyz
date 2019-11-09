provider "aws" {
  region             = "ap-southeast-2"
}

variable "www_domain_name" {
  default = "www.joelfreeman.xyz"
}

variable "root_domain_name" {
  default = "joelfreeman.xyz"
}

resource "aws_s3_bucket" "www" {
  bucket = "${var.root_domain_name}"
  acl    = "public-read"
  policy = <<POLICY
{
  "Version":"2012-10-17",
  "Statement":[
    {
      "Sid":"AddPerm",
      "Effect":"Allow",
      "Principal": "*",
      "Action":["s3:GetObject"],
      "Resource":["arn:aws:s3:::${var.www_domain_name}/*"]
    }
  ]
}
POLICY

  website {
    index_document = "index.html"
    error_document = "404.html"
  }
}

resource "aws_acm_certificate" "cert" {
    domain_name       = "joelfreeman.xyz"
      validation_method = "DNS"
}

data "aws_route53_zone" "zone" {
    name         = "joelfreeman.xyz"
      private_zone = false
}

resource "aws_route53_record" "cert_validation" {
    name    = "${aws_acm_certificate.cert.domain_validation_options.0.resource_record_name}"
      type    = "${aws_acm_certificate.cert.domain_validation_options.0.resource_record_type}"
        zone_id = "${data.aws_route53_zone.zone.id}"
	  records = ["${aws_acm_certificate.cert.domain_validation_options.0.resource_record_value}"]
	    ttl     = 60
}

resource "aws_acm_certificate_validation" "cert" {
    certificate_arn         = "${aws_acm_certificate.cert.arn}"
      validation_record_fqdns = ["${aws_route53_record.cert_validation.fqdn}"]
}

