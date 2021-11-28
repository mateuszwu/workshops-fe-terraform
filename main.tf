locals {
  s3_origin_id = "mwieczorek-frontend-application-bucket"
  app_folder   = "app"
}

resource "aws_s3_bucket" "fe_app" {
  bucket = "mwieczorek-frontend-application-bucket"
  acl    = "private"
}

data "aws_iam_policy_document" "fe_app" {
  version = "2012-10-17"

  statement {
    actions = [
      "s3:GetObject",
    ]
    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.fe_app.iam_arn]
    }

    resources = ["${aws_s3_bucket.fe_app.arn}/${local.app_folder}/*"]
  }
}

resource "aws_s3_bucket_policy" "fe_app" {
  bucket = aws_s3_bucket.fe_app.id
  policy = data.aws_iam_policy_document.fe_app.json
}

resource "aws_cloudfront_origin_access_identity" "fe_app" {
}

resource "aws_cloudfront_distribution" "fe_app" {
  enabled             = true
  price_class         = "PriceClass_100"
  default_root_object = "index.html"
  is_ipv6_enabled     = true
  aliases             = ["mwieczorek.workshops.selleo.app"]

  origin {
    domain_name = aws_s3_bucket.fe_app.bucket_regional_domain_name
    origin_id   = local.s3_origin_id
    origin_path = "/${local.app_folder}"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.fe_app.cloudfront_access_identity_path
    }
  }

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.s3_origin_id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = false
    acm_certificate_arn            = aws_acm_certificate.fe_app.arn
    minimum_protocol_version       = "TLSv1.2_2019"
    ssl_support_method             = "sni-only"
  }
}

output "cloudfront_address" {
  value = aws_cloudfront_distribution.fe_app.domain_name
}

output "cloudfront_distribution_id" {
  value = aws_cloudfront_distribution.fe_app.id
}

data "aws_route53_zone" "fe_app" {
  name         = "workshops.selleo.app"
  private_zone = false
}

resource "aws_route53_record" "fe_app" {
  zone_id = data.aws_route53_zone.fe_app.zone_id
  name    = "mwieczorek"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.fe_app.domain_name
    zone_id                = aws_cloudfront_distribution.fe_app.hosted_zone_id
    evaluate_target_health = true
  }
}

output "aws_route53_record_name" {
  value = aws_route53_record.fe_app.name
}

resource "aws_acm_certificate" "fe_app" {
  provider = aws.global

  domain_name       = "mwieczorek.workshops.selleo.app"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "fe_app_cert" {
  for_each = {
    for dvo in aws_acm_certificate.fe_app.domain_validation_options : dvo.domain_name => {
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
  zone_id         = data.aws_route53_zone.fe_app.zone_id
}

module "ci_user_1" {
  source = "./modules/iam_user_with_access_key"
  name   = "ci_user_1"
}

module "ci_user_2" {
  source = "./modules/iam_user_with_access_key"
  name   = "ci_user_2"
}

module "s3_write_policy_for_users" {
  source = "./modules/iam_s3_full_access_policy"
  s3     = aws_s3_bucket.fe_app.arn
  users = [
    module.ci_user_1.IAM_user_name,
    module.ci_user_2.IAM_user_name
  ]
}

module "cloudfront_invalidation_access2" {
  source     = "./modules/iam_cloudfront_invalidate_policy"
  cloudfront = aws_cloudfront_distribution.fe_app.arn
  users = [
    module.ci_user_1.IAM_user_name,
    module.ci_user_2.IAM_user_name
  ]
}
