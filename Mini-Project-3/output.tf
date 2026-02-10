# output "user_names" {
#  value = [for user in local.users: "${user.first_name} ${user.last_name}"]
# }

# output "user_password" {
#    value = {
#     for user, profile in aws_iam_user_login_profile.login_profile: 
#     user => "password created, reset should be done immediately after first login"
#    }
#    sensitive = false
# }

# output "engineers" {
#     value = aws_iam_group_membership.engineers.name
# }
# output "toplevel" {
#     value = aws_iam_group_membership.toplevel.name
# }
# output "sales" {
#     value = aws_iam_group_membership.sales.name
# }