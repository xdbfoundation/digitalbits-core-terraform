resource "aws_s3_bucket" "toml" {
  bucket        = var.bucket_name
  force_destroy = true
  acl           = "public-read"
  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "HEAD"]
    allowed_origins = ["*"]
    expose_headers  = []
    max_age_seconds = 3000
  }
}

resource "aws_s3_bucket_object" "object" {
  depends_on = [
    aws_s3_bucket.toml
  ]
  force_destroy = true
  bucket = var.bucket_name
  key    = "/.well-known/digitalbits.toml"
  content = templatefile("${path.module}/digitalbits.tpl", {
    org_name    = var.org_name
    org_name_lc = lower(var.org_name)
    domain_name = var.domain_name,
    keys        = var.keys
    accounts    = jsonencode([for e in values(var.keys) : e.public])
  })
}

resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {}

resource "aws_cloudfront_distribution" "toml_distribution" {
  price_class = "PriceClass_All"
  aliases     = [var.toml_zone_record]
  origin {
    domain_name = aws_s3_bucket.toml.bucket_domain_name
    origin_id   = join("-", ["S3", var.bucket_name])
  }
  enabled         = true
  is_ipv6_enabled = true

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = join("-", ["S3", var.bucket_name])

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 86400
    max_ttl                = 31536000
  }

  viewer_certificate {
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2019"
    acm_certificate_arn      = var.cert.arn
  }
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
}


resource "aws_route53_record" "toml_record" {
  zone_id = var.zone_id
  name    = var.toml_zone_record
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.toml_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.toml_distribution.hosted_zone_id
    evaluate_target_health = false
  }
}
