locals {
  app_folder = "app"
  origin_id  = "app"
}

resource "aws_s3_bucket" "frontend_application" {
  bucket = "lpawlik-selleo-frontend-application"
  acl    = "private"
}

data "aws_iam_policy_document" "frontend_application" {
  version = "2012-10-17"
  statement {
    actions = [
      "s3:GetObject"
    ]

    resources = [
      "${aws_s3_bucket.frontend_application.arn}/${local.app_folder}/*"
    ]

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
  }
}

resource "aws_s3_bucket_policy" "frontend_application" {
  bucket = aws_s3_bucket.frontend_application.id
  policy = data.aws_iam_policy_document.frontend_application.json
}


resource "aws_cloudfront_origin_access_identity" "frontend_application" {
  comment = "Luke's Workshop app"
}

resource "aws_cloudfront_distribution" "frontend_application" {
  comment             = "Luke's Workshop app"
  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"
  aliases             = []
  price_class         = "PriceClass_100"

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  origin {
    origin_id   = local.origin_id
    origin_path = "/${local.app_folder}"
    domain_name = aws_s3_bucket.frontend_application.bucket_regional_domain_name

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.frontend_application.cloudfront_access_identity_path
    }
  }

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.origin_id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    compress               = true
    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
}
