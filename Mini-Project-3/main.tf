# resource "aws_iam_user" "users" {
#   for_each = {for user in local.users: user.first_name => user}
#   name = lower("${substr(each.value.first_name, 0, 1)}${each.value.last_name}")
#   path = "/users/"

#   tags = {
#     "Fullname" = "${each.value.first_name} ${each.value.last_name}"
#     "Department" = each.value.department
#     "JobTitle" = each.value.job_title
#   }
# }

# resource "aws_iam_user_login_profile" "login_profile" {
#   for_each = aws_iam_user.users
  
#   user    = each.value.name
#   password_reset_required = true

#   lifecycle {
#     ignore_changes = [ password_length, password_reset_required ]
#   }
# }

resource "aws_identitystore_user" "users" {
  identity_store_id = tolist(data.aws_ssoadmin_instances.users.identity_store_ids)[0]

  for_each = {for user in local.users: user.first_name => user}
  display_name = "${each.value.first_name} ${each.value.last_name}"
  user_name    = lower("${substr(each.value.first_name, 0, 1)}${each.value.last_name}")
  title = each.value.job_title

  name {
    given_name  = each.value.first_name
    family_name = each.value.last_name
  }


}
