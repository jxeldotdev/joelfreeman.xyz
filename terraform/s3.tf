resource "aws_s3_bucket" "s3_bucket" {
  bucket = var.bucket_name
  force_destroy = true
  
  website {
    index_document = "index.html"
    error_document = "404.html"
  }
}

resource "aws_s3_bucket_policy" "s3_bucket_policy" {
  bucket = var.bucket_name
  
  policy = <<EOF
{
  "Version":"2012-10-17",
  "Id":"S3_CLOUDFRONT_ONLY_ACCESS",
  "Statement":[
    {
      "Sid":"Grant a CloudFront Origin Identity access to support private content",
      "Effect":"Allow",
      "Principal":{"CanonicalUser":"${aws_cloudfront_origin_access_identity.origin_access_identity.s3_canonical_user_id}"},
      "Action": [
        "s3:GetObject",
        "s3:ListBucket"
      ],
      "Resource": [
        "arn:aws:s3:::${var.bucket_name}/*",
        "arn:aws:s3:::${var.bucket_name}"
      ]
    }
  ]
}
EOF

  depends_on = ["aws_cloudfront_origin_access_identity.origin_access_identity", "aws_s3_bucket.s3_bucket"]
}