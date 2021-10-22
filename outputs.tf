output "cloudfront_distribution_id" {
  description = "cf dist id"
  value       = aws_cloudfront_distribution.frontend_application.id
}

output "cloudfront_address" {
  description = "cloudfront address"
  value       = aws_cloudfront_distribution.frontend_application.domain_name
}
