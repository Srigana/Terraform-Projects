locals {
  formatted_project_name = lower(var.project_name)
  new_tags               = merge(var.environment_tags, var.default_tags)
  formatted_bucket_name = replace(replace(
    substr(lower(var.bucket_name), 0, 63),
  " ", ""), "!", "")
}
