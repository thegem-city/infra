resource "aws_iam_user" "thegemcity" {
  name = "thegemcity"
}

resource "aws_iam_access_key" "thegemcity" {
  user = aws_iam_user.thegemcity.name
}

data "aws_iam_policy_document" "thegemcity" {
  statement {
    effect = "Allow"
    actions = [
      "s3:*",
    ]
    resources = [
      "${aws_s3_bucket.files.arn}",
      "${aws_s3_bucket.files.arn}/*",
      "${aws_s3_bucket.backups.arn}",
      "${aws_s3_bucket.backups.arn}/*",
    ]
  }
  statement {
    effect    = "Allow"
    actions   = ["s3:ListAllMyBuckets"]
    resources = ["*"]
  }
}

resource "aws_iam_user_policy" "thegemcity" {
  user   = aws_iam_user.thegemcity.name
  policy = data.aws_iam_policy_document.thegemcity.json
}

# output "thegemcity_credentials" {
#   value = {
#     "${aws_iam_access_key.thegemcity.id}" : "${aws_iam_access_key.thegemcity.secret}"
#   }
#   sensitive = true
# }
