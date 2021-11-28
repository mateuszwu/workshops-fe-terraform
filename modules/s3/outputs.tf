output "S3_arn" {
  value = aws_s3_bucket.this.arn
}

output "S3_bucket_regional_domain_name" {
  value = aws_s3_bucket.this.bucket_regional_domain_name
}
