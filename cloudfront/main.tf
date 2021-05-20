# --- cloudfront/main.tf ---
resource "aws_s3_bucket" "history_archive" {
  force_destroy = true
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }

  }
  bucket = var.bucket_name
  acl    = "private"
  tags = {
    Name = "Livenet history archive"
  }
}

resource "aws_s3_bucket_policy" "read" {
  bucket = aws_s3_bucket.history_archive.id
  policy = data.aws_iam_policy_document.read_s3.json
}

resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {}
resource "aws_cloudfront_distribution" "history_distribution" {
  web_acl_id  = aws_wafv2_web_acl.cloudfront_waf.arn
  price_class = "PriceClass_200"
  aliases     = [var.history_zone_record]
  origin {
    domain_name = aws_s3_bucket.history_archive.bucket_regional_domain_name
    origin_id   = local.s3_origin_id
    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.origin_access_identity.cloudfront_access_identity_path
    }
  }
  enabled             = true
  is_ipv6_enabled     = false
  default_root_object = "index.html"
  tags = {
    Name = "Livenet history archive"
  }
  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = local.s3_origin_id

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 86400
    max_ttl                = 86400
  }
  ordered_cache_behavior {
    path_pattern     = "*/.well-known/digitalbits-history.json"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = local.s3_origin_id

    forwarded_values {
      query_string = false
      headers      = ["Origin"]

      cookies {
        forward = "none"
      }
    }

    min_ttl                = 0
    default_ttl            = 0
    max_ttl                = 0
    compress               = true
    viewer_protocol_policy = "redirect-to-https"
  }

  dynamic "custom_error_response" {
    for_each = [400, 403, 404, 405, 414, 416]
    content {
      error_code            = custom_error_response.value
      error_caching_min_ttl = 0
    }
  }
  viewer_certificate {
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1"
    #cloudfront_default_certificate = true
    acm_certificate_arn = var.cert.arn
  }
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
}

resource "aws_wafv2_web_acl" "cloudfront_waf" {
  name        = "CloudFront"
  description = "Livenet History WAF"
  scope       = "CLOUDFRONT"

  default_action {
    allow {}
  }

  rule {
    name     = "RateLimiting"
    priority = 0

    action {
      count {}
    }

    statement {
      rate_based_statement {
        limit              = 20000
        aggregate_key_type = "IP"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "RateLimiting"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "AWS-AWSManagedRulesAmazonIpReputationList"
    priority = 1
    override_action {
      count {}
    }
    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesAmazonIpReputationList"
        vendor_name = "AWS"
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWSManagedRulesAmazonIpReputationList"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "AWS-AWSManagedRulesCommonRuleSet"
    priority = 2
    override_action {
      count {}
    }
    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWSManagedRulesCommonRuleSet"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "AWS-AWSManagedRulesLinuxRuleSet"
    priority = 3
    override_action {
      count {}
    }
    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesLinuxRuleSet"
        vendor_name = "AWS"
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWSManagedRulesLinuxRuleSet"
      sampled_requests_enabled   = true
    }
  }
  rule {
    name     = "AWS-AWSManagedRulesUnixRuleSet"
    priority = 4
    override_action {
      count {}
    }
    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesLinuxRuleSet"
        vendor_name = "AWS"
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWSManagedRulesLinuxRuleSet"
      sampled_requests_enabled   = true
    }
  }
  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "DefaultBehavior"
    sampled_requests_enabled   = true
  }
}

resource "aws_route53_record" "history_record" {
  zone_id = var.zone_id
  name    = var.history_zone_record
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.history_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.history_distribution.hosted_zone_id
    evaluate_target_health = false
  }
}
