resource "aws_s3_bucket" "this" {
  bucket = var.bucket_name
  acl    = "private"
}

data "aws_iam_policy_document" "this" {
  version = "2012-10-17"

  statement {
    actions = [
      "s3:GetObject",
    ]
    principals {
      type        = "AWS"
      identifiers = var.principals_identifiers
    }

    resources = ["${aws_s3_bucket.this.arn}/${var.app_folder}/*"]
  }
}

resource "aws_s3_bucket_policy" "this" {
  bucket = aws_s3_bucket.this.id
  policy = data.aws_iam_policy_document.this.json
}
