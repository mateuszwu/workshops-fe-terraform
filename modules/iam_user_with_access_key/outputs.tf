output "IAM_user_name" {
  value = var.name
}

output "IAM_user_id" {
  value = aws_iam_access_key.this.id
}

output "IAM_user_secret" {
  value     = aws_iam_access_key.this.secret
  sensitive = true
}
