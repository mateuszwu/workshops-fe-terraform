data "aws_iam_policy_document" "this" {
  version = "2012-10-17"

  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:DeleteObject",
      "s3:PutObject",
    ]

    resources = [
      "${var.s3}/*"
    ]
  }

  statement {
    actions = [
      "s3:ListBucket",
      "s3:GetBucketLocation",
    ]

    resources = [
      var.s3
    ]
  }
}

resource "aws_iam_policy" "this" {
  policy = data.aws_iam_policy_document.this.json
}

resource "aws_iam_policy_attachment" "this" {
  name       = "S3-full-access"
  users      = var.users
  policy_arn = aws_iam_policy.this.arn
}
