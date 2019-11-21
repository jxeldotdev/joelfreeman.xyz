variable "bucket_name" {}

variable "domain_name" {}

variable "origin_id" {}

variable "region" {}

provider "aws" {
  region = var.region
}

provider "aws" {
  region = var.cloudfront_region
  alias = "cloudfront_region"
}
