resource "aws_iam_role" "ecs_service" {
  name               = "${var.ecs_base_cluster_name}-${var.environment}-service-role"
  assume_role_policy = "${file("${path.module}/files/ecs_assume_role.json")}"
}

resource "aws_iam_role_policy" "ecs_service" {
  name   = "${var.ecs_base_cluster_name}-${var.environment}-service-role-policy"
  role   = "${aws_iam_role.ecs_service.name}"
  policy = "${file("${path.module}/files/ecs_service_role_policy.json")}"
}
