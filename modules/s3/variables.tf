variable "bucket_name" {
  type        = string
  description = "S3 bucket name"
}

variable "app_folder" {
  type        = string
  description = "S3 application folder"
}

variable "principals_identifiers" {
  type        = set(string)
  description = "AWS principals identifiers"

}
