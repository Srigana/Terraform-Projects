data "aws_caller_identity" "identity" {

}

# data "aws_iam_policy_document" "policy" {
  # statement {
  #   sid    = "Statement1"
  #   effect = "Allow"

  #   actions = [
  #     "s3:CreateBucket",
  #   ]

  #   resources = [
  #     "*",
  #   ]
  # }
# }

data "aws_ssoadmin_instances" "users" {}

output "account_id" {
  value = data.aws_caller_identity.identity
}