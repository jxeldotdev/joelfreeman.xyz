variable "bucket_name" {}

variable "domain_name" {}

variable "origin_id" {}

variable "region" {}

provider "aws" {
  region = var.region
}
// we need this for creating the ssl cert 
provider "aws" {
  region = "us-east-1"
  alias = "us-east-1"
}

resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
  
}

// Create S3 bucket. This is used as hosting for the static website.
resource "aws_s3_bucket" "site_bucket" {
  bucket = var.bucket_name
  force_destroy = true
  
  website {
    index_document = "index.html"
    error_document = "404.html"
  }
}
// s3 bucket policy , only allow CloudFront access to it 
resource "aws_s3_bucket_policy" "site_bucket_policy" {
  bucket = "${aws_s3_bucket.site_bucket.bucket}"
  
  policy = <<POLICY
  {
    "Version":"2012-10-17",
    "Id":"S3_CLOUDFRONT_ONLY_ACCESS",
    "Statement":[
      {
        "Sid":"Grant a CloudFront Origin Identity access to support private content",
        "Effect":"Allow",
        "Principal":{"CanonicalUser":"${aws_cloudfront_origin_access_identity.origin_access_identity.s3_canonical_user_id}"},
        "Action":"s3:GetObject",
        "Resource":"arn:aws:s3:::${var.bucket_name}/*"
      }
    ]
  }
  POLICY
}

resource "aws_iam_role" "lambda_iam_role" {
  name = "iam_lambda_s3"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_lambda_function" "s3_lambda_redirect" {
  filename = "lambda_function.zip"
  function_name = "lambda_s3_cloudfront_subdirectory_default_index"
  role = "${aws_iam_role.lambda_iam_role.arn}"
  handler = "index.handler"
  runtime = "nodejs8.10"
}


// Pull in data from Route53 zone so we can create dns records for SSL Certificate Validation
data "aws_route53_zone" "hosted_zone" { 
    name         = var.domain_name
    private_zone = false
}

// Create SSL certificate for CloudFront Distribution
resource "aws_acm_certificate" "ssl_cert" { 
  provider = "aws.us-east-1"
  domain_name       = var.domain_name
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}


// Create SSL certificate verification records
resource "aws_route53_record" "ssl_cert_dns_validation_records" { 
    name        = "${aws_acm_certificate.ssl_cert.domain_validation_options.0.resource_record_name}"
    type        = "${aws_acm_certificate.ssl_cert.domain_validation_options.0.resource_record_type}"
    zone_id     = "${data.aws_route53_zone.hosted_zone.id}"
	  records     = ["${aws_acm_certificate.ssl_cert.domain_validation_options.0.resource_record_value}"]
	  ttl         = 60
}

// Verify newly created SSL certificate with records above
resource "aws_acm_certificate_validation" "ssl_cert_validation" { 
    provider = "aws.us-east-1"
    certificate_arn           = "${aws_acm_certificate.ssl_cert.arn}"
    validation_record_fqdns   = ["${aws_route53_record.ssl_cert_dns_validation_records.fqdn}"]
}


// Create Cloudfront Distribution
resource "aws_cloudfront_distribution" "s3_cloudfront_distribution" {
  origin {
    domain_name = "${aws_s3_bucket.site_bucket.bucket_regional_domain_name}"
    origin_id = var.origin_id

    s3_origin_config {
      origin_access_identity = "${aws_cloudfront_origin_access_identity.origin_access_identity.cloudfront_access_identity_path}"
    }
  }

  enabled = true
  is_ipv6_enabled = true
  default_root_object = "index.html"

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
        lambda_arn = "${aws_lambda_function.s3_lambda_redirect.qualified_arn}"
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

  

  depends_on = ["aws_acm_certificate_validation.ssl_cert_validation", "aws_s3_bucket.site_bucket"]
}

resource "aws_route53_record" "cloudfront_a_record" {
  zone_id = "${data.aws_route53_zone.hosted_zone.id}"
  name    = "${var.domain_name}"
  type    = "A"
  
  alias {
    name = replace(aws_cloudfront_distribution.s3_cloudfront_distribution.domain_name, "/[.]$/", "")
    zone_id = "${aws_cloudfront_distribution.s3_cloudfront_distribution.hosted_zone_id}"
    evaluate_target_health = true
  }

  depends_on = [aws_cloudfront_distribution.s3_cloudfront_distribution]
}


