
resource "aws_cloudwatch_dashboard" "main" {
  count = var.dashboard_name != "" ? 1 : 0

  dashboard_name = var.dashboard_name

  dashboard_body = templatefile("${path.module}/dashboard.json.tftpl", {
    region           = data.aws_region.current.name
    ec2_instances    = var.ec2_instance_ids
    rds_instance_id  = var.rds_instance_id
    ecs_cluster_name = var.ecs_cluster_name
    ecs_service_name = var.ecs_service_name
    alb_arn_suffix   = var.alb_arn_suffix
  })
}