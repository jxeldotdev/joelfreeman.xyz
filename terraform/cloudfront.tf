resource "aws_acm_certificate" "ssl_cert" { 
  provider = "aws.cloudfront_region"
  domain_name       = var.domain_name
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_acm_certificate_validation" "ssl_cert_validation" { 
    provider = "aws.cloudfront_region"
    certificate_arn           = "${aws_acm_certificate.ssl_cert.arn}"
    validation_record_fqdns   = ["${aws_route53_record.ssl_cert_dns_validation_records.fqdn}"]

    depends_on = ["aws_acm_certificate.ssl_cert", "aws_route53_record.ssl_cert_dns_validation_records"]
}

resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
  comment = "Origin Access Identity for CloudFront"
}

resource "aws_cloudfront_distribution" "cloudfront_distribution" {
  origin {
    domain_name = "${aws_s3_bucket.s3_bucket.bucket_regional_domain_name}"
    origin_id = var.origin_id

    s3_origin_config {
      origin_access_identity = "${aws_cloudfront_origin_access_identity.origin_access_identity.cloudfront_access_identity_path}"
    }
  }

  enabled = true
  is_ipv6_enabled = true
  default_root_object = "index.html"
  price_class = "PriceClass_100"

  aliases = ["joelfreeman.xyz"]

  default_cache_behavior {
    allowed_methods = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods = ["GET", "HEAD"]
    target_origin_id = var.origin_id
    
    forwarded_values {
      query_string = true

      cookies {
        forward = "none"
      }
    }


    viewer_protocol_policy = "redirect-to-https"
    min_ttl = 0
    default_ttl = 3600
    max_ttl = 86400

    lambda_function_association {
        event_type = "viewer-request"
        lambda_arn = "${aws_lambda_function.lambda_cloudfront_redirect.qualified_arn}"
        include_body = true
    }
    
  }
  
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn = "${aws_acm_certificate.ssl_cert.arn}"
    ssl_support_method = "sni-only"
    cloudfront_default_certificate = false
  }

  depends_on = ["aws_acm_certificate_validation.ssl_cert_validation", "aws_acm_certificate.ssl_cert", "aws_s3_bucket.s3_bucket", "aws_cloudfront_origin_access_identity.origin_access_identity"]
}
