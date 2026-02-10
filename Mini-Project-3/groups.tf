# resource "aws_iam_group" "sales" {
#   name = "Sales"
#   path = "/groups/"

# }


# resource "aws_iam_group" "toplevel" {
#   name = "Toplevel"
#   path = "/groups/"
# }

# resource "aws_iam_group" "engineers" {
#   name = "Engineers"
#   path = "/groups/"
# }

# resource "aws_iam_group_membership" "sales" {
#   name = "sales-group-membership"
#   group = aws_iam_group.sales.name

#   users = [
#     for user in aws_iam_user.users: user.name if user.tags.Department == "Sales"
#   ]

# }

# resource "aws_iam_group_membership" "toplevel" {
#   name = "toplevel-group-membership"
#   group = aws_iam_group.toplevel.name

#   users = [
#     for user in aws_iam_user.users: user.name if contains(keys(user.tags), "JobTitle") && can(regex("CEO|Manager", user.tags.JobTitle))
#   ]

# }

# resource "aws_iam_group_membership" "engineers" {
#   name = "engineers-group-membership"
#   group = aws_iam_group.engineers.name

#   users = [
#     for user in aws_iam_user.users: user.name if user.tags.Department == "Engineers"
#   ]

# }

# resource "aws_iam_group_policy" "policy" {
#   name        = "test_policy"
#   group = aws_iam_group.sales.name
#   policy = data.aws_iam_policy_document.policy.json
# }

# resource "aws_iam_group_policy" "enable_mfa"{
#     name = "mfa_policy"
#     group = aws_iam_group.engineers.name
#     policy = jsonencode({
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Sid": "Statement1",
#       "Effect": "Deny",
#       "Action": [
#         "iam:CreateVirtualMFADevice",
#         "iam:EnableMFADevice",
#         "iam:ListMFADeviceTags",
#         "iam:ListVirtualMFADevices",
#         "iam:ListMFADevices",
#         "iam:GetUser"
#       ],
#       "Resource": "*"
#     }
#   ]
#     })
# }

resource "aws_identitystore_group" "sales" {
  display_name      = "Sales group"
  description       = "This is a sales group"
  identity_store_id = tolist(data.aws_ssoadmin_instances.users.identity_store_ids)[0]
}

resource "aws_identitystore_group" "toplevel" {
  display_name      = "Toplevel group"
  description       = "This is a toplevel group"
  identity_store_id = tolist(data.aws_ssoadmin_instances.users.identity_store_ids)[0]
}

resource "aws_identitystore_group" "engineers" {
  display_name      = "Engineers group"
  description       = "This is a engineers group"
  identity_store_id = tolist(data.aws_ssoadmin_instances.users.identity_store_ids)[0]
}

resource "aws_identitystore_group_membership" "sales_group" {
  for_each = {for user in local.users: user.first_name => user if user.department == "Sales"}
  identity_store_id = tolist(data.aws_ssoadmin_instances.users.identity_store_ids)[0]
  group_id          = aws_identitystore_group.sales.group_id
  member_id         = aws_identitystore_user.users[each.key].user_id
}

resource "aws_identitystore_group_membership" "toplevel_group" {
  for_each = {for user in local.users: user.first_name => user if can(regex("CEO|Manager", user.job_title))}
  identity_store_id = tolist(data.aws_ssoadmin_instances.users.identity_store_ids)[0]
  group_id          = aws_identitystore_group.toplevel.group_id
  member_id         = aws_identitystore_user.users[each.key].user_id
}

resource "aws_identitystore_group_membership" "engineer_group" {
  for_each = {for user in local.users: user.first_name => user if user.department == "Engineer"}
  identity_store_id = tolist(data.aws_ssoadmin_instances.users.identity_store_ids)[0]
  group_id          = aws_identitystore_group.engineers.group_id
  member_id         = aws_identitystore_user.users[each.key].user_id
}

resource "aws_ssoadmin_permission_set" "engineers" {
  name             = "EngineerAccess"
  instance_arn     = tolist(data.aws_ssoadmin_instances.users.arns)[0]
}

resource "aws_ssoadmin_permission_set_inline_policy" "engineers" {
  instance_arn       = tolist(data.aws_ssoadmin_instances.users.arns)[0]
  permission_set_arn = aws_ssoadmin_permission_set.engineers.arn
  
  # Just load your JSON file here
  inline_policy      = file("${path.module}/policies.json")
}