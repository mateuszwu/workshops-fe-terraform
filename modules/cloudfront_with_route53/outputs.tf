
output "CLOUDFRONT_domain_name" {
  value = aws_cloudfront_distribution.this.domain_name
}

output "CLOUDFRONT_distribution_id" {
  value = aws_cloudfront_distribution.this.id
}

output "CLOUDFRONT_distribution_arn" {
  value = aws_cloudfront_distribution.this.arn
}

output "ROUTE53_record_name" {
  value = aws_route53_record.this.name
}

output "CLOUDDFRONT_origin_access_identity_iam_arn" {
  value = aws_cloudfront_origin_access_identity.this.iam_arn
}
