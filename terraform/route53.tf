data "aws_route53_zone" "hosted_zone" { 
    name         = var.domain_name
    private_zone = false
}

resource "aws_route53_record" "ssl_cert_dns_validation_records" { 
    name        = "${aws_acm_certificate.ssl_cert.domain_validation_options.0.resource_record_name}"
    type        = "${aws_acm_certificate.ssl_cert.domain_validation_options.0.resource_record_type}"
    zone_id     = "${data.aws_route53_zone.hosted_zone.id}"
    records     = ["${aws_acm_certificate.ssl_cert.domain_validation_options.0.resource_record_value}"]
    ttl         = 60

    depends_on = ["aws_acm_certificate.ssl_cert"]
}

resource "aws_route53_record" "cloudfront_a_record" {
  zone_id = "${data.aws_route53_zone.hosted_zone.id}"
  name    = "${var.domain_name}"
  type    = "A"
  
  alias {
    name = replace(aws_cloudfront_distribution.cloudfront_distribution.domain_name, "/[.]$/", "")
    zone_id = "${aws_cloudfront_distribution.cloudfront_distribution.hosted_zone_id}"
    evaluate_target_health = true
  }

  depends_on = ["aws_cloudfront_distribution.cloudfront_distribution"]
}
