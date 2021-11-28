variable "cloudfront" {
  type        = string
  description = "Cloudfront ARN"
}

variable "users" {
  type        = set(string)
  description = "IAM user name"
}
