data "aws_iam_policy_document" "this" {
  version = "2012-10-17"

  statement {
    effect = "Allow"
    actions = [
      "cloudfront:CreateInvalidation",
    ]

    resources = [
      var.cloudfront
    ]
  }
}

resource "aws_iam_policy" "this" {
  policy = data.aws_iam_policy_document.this.json
}

resource "aws_iam_policy_attachment" "this" {
  name       = "Cloudfront-invalidation-access"
  users      = var.users
  policy_arn = aws_iam_policy.this.arn
}
