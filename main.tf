locals {
  app_folder = "app"
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
      identifiers = ["*"]
    }
  }
}

resource "aws_s3_bucket_policy" "frontend_application" {
  bucket = aws_s3_bucket.frontend_application.id
  policy = data.aws_iam_policy_document.frontend_application.json
}
