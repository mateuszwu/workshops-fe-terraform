locals {
  app_folder    = "app"
  origin_id     = "app"
  domain        = "workshops.selleo.app"
  app_subdomain = "lpawlik"
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
      identifiers = [aws_cloudfront_origin_access_identity.frontend_application.iam_arn]
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
  aliases             = ["${local.app_subdomain}.${local.domain}"]
  price_class         = "PriceClass_100"

  viewer_certificate {
    cloudfront_default_certificate = false
    acm_certificate_arn            = aws_acm_certificate.lpawlik_workshops_selleo_app.arn
    minimum_protocol_version       = "TLSv1.2_2019"
    ssl_support_method             = "sni-only"
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

data "aws_route53_zone" "workshops_selleo_app" {
  name         = local.domain
  private_zone = false
}

resource "aws_route53_record" "frontend_app" {
  zone_id = data.aws_route53_zone.workshops_selleo_app.zone_id
  name    = local.app_subdomain
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.frontend_application.domain_name
    zone_id                = aws_cloudfront_distribution.frontend_application.hosted_zone_id
    evaluate_target_health = true
  }
}

resource "aws_acm_certificate" "lpawlik_workshops_selleo_app" {
  provider = aws.global

  domain_name       = "${local.app_subdomain}.${local.domain}"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "lpawlik_workshops_selleo_app" {
  provider = aws.global

  for_each = {
    for dvo in aws_acm_certificate.lpawlik_workshops_selleo_app.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.workshops_selleo_app.zone_id
}

resource "aws_iam_user" "ci_user" {
  name = "lpawlik-ci-user"
}

resource "aws_iam_access_key" "ci_user" {
  user = aws_iam_user.ci_user.name
}

data "aws_iam_policy_document" "frontend_app_ci_s3_access" {
  statement {
    actions = [
      "s3:ListBucket",
      "s3:GetBucketLocation",
    ]
    resources = [
      aws_s3_bucket.frontend_application.arn
    ]
  }

  statement {
    actions = [
      "s3:PutObject",
      "s3:DeleteObject",
    ]
    resources = [
      "${aws_s3_bucket.frontend_application.arn}/*"
    ]
  }
}

resource "aws_iam_policy" "frontend_app_ci_s3_access" {
  name        = "lpawlik_ci_s3_access_policy"
  description = "Allows CI user to sync files with s3"
  policy      = data.aws_iam_policy_document.frontend_app_ci_s3_access.json
}

resource "aws_iam_user_policy_attachment" "frontend_app_ci_s3_access" {
  user       = aws_iam_user.ci_user.name
  policy_arn = aws_iam_policy.frontend_app_ci_s3_access.arn
}

data "aws_iam_policy_document" "frontend_app_ci_cdn_invalidation" {
  statement {
    actions = [
      "cloudfront:CreateInvalidation"
    ]

    resources = [
      aws_cloudfront_distribution.frontend_application.arn
    ]
  }
}

resource "aws_iam_policy" "frontend_app_ci_cdn_invalidation" {
  name        = "lpawlik_ci_cf_invalidation_policy"
  description = "Allows CI user to invalidate cloudfront cache"
  policy      = data.aws_iam_policy_document.frontend_app_ci_cdn_invalidation.json
}

resource "aws_iam_user_policy_attachment" "frontend_app_ci_cdn_invalidation" {
  user       = aws_iam_user.ci_user.name
  policy_arn = aws_iam_policy.frontend_app_ci_cdn_invalidation.arn
}
