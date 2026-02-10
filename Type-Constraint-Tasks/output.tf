output "deployment_summary" {
  value = {
    environment    = var.environment
    instance_count = var.instance_count
    name           = var.instance_tags["Name"]
  }
}
