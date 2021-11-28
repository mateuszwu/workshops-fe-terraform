locals {
  s3_origin_id = "mwieczorek-frontend-application-bucket"
  app_folder   = "app"
}

module "s3" {
  source = "./modules/s3"

  bucket_name = local.s3_origin_id
  app_folder = local.app_folder
  principals_identifiers = [module.cloudfront.CLOUDDFRONT_origin_access_identity_iam_arn]
}

module "cloudfront" {
  source = "./modules/cloudfront_with_route53"

  origin = {
    domain_name = module.s3.S3_bucket_regional_domain_name
    origin_id   = local.s3_origin_id
    origin_path = local.app_folder
  }

  route53 = {
    zone_name = "workshops.selleo.app"
    domain_name = "mwieczorek.workshops.selleo.app"
  }

  providers = {
    aws = aws.global
  }
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
  s3     = module.s3.S3_arn
  users = [
    module.ci_user_1.IAM_user_name,
    module.ci_user_2.IAM_user_name
  ]
}

module "cloudfront_invalidation_access2" {
  source     = "./modules/iam_cloudfront_invalidate_policy"
  cloudfront = module.cloudfront.CLOUDFRONT_distribution_arn
  users = [
    module.ci_user_1.IAM_user_name,
    module.ci_user_2.IAM_user_name
  ]
}
