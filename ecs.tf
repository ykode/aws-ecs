output "ecs_cluster_name" {
  value = "${var.ecs_base_cluster_name}-${var.environment}"
}

resource "aws_iam_role" "ecs_instance" {
  name               = "${var.ecs_base_cluster_name}-${var.environment}-instance-role"
  assume_role_policy = "${file("${path.module}/files/ecs_assume_role.json")}"
}

resource "aws_iam_role_policy" "ecs_instance" {
  name   = "${var.ecs_base_cluster_name}-${var.environment}-instance-role-policy"
  role   = "${aws_iam_role.ecs_instance.name}"
  policy = "${file("${path.module}/files/ecs_instance_role_policy.json")}"
}

resource "aws_iam_instance_profile" "ecs" {
  name = "${var.ecs_base_cluster_name}-${var.environment}-instance-profile"
  path = "/"
  role = "${aws_iam_role.ecs_instance.name}"
}

data "aws_ami" "amazon_ecs" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn-ami-*-amazon-ecs-optimized"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["591542846629"] # Amazon
}

resource "aws_security_group" "ecs_instance" {
  name        = "${format("%s-%s-ecs-sg", var.ecs_base_cluster_name, var.environment)}"
  description = "Security for ECS Instances"
  vpc_id      = "${aws_vpc.main.id}"

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = ["${aws_security_group.external_ssh.id}"]
  }

  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "tcp"
    security_groups = ["${aws_security_group.load_balancer.id}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }

  tags {
    Name        = "${format("%s-%s-ecs-sg", var.ecs_base_cluster_name, var.environment)}"
    Environment = "${var.environment}"
  }
}

resource "aws_launch_configuration" "ecs_instance" {
  security_groups = [
    "${aws_security_group.ecs_instance.id}",
  ]

  key_name                    = "${aws_key_pair.main.key_name}"
  image_id                    = "${data.aws_ami.amazon_ecs.id}"
  instance_type               = "${var.ecs_instance_type}"
  iam_instance_profile        = "${aws_iam_instance_profile.ecs.name}"
  user_data                   = "#!/bin/bash\necho ECS_CLUSTER='${var.ecs_base_cluster_name}-${var.environment}' > /etc/ecs/ecs.config"
  associate_public_ip_address = false

  # root
  root_block_device {
    volume_type = "gp2"
    volume_size = "${var.ecs_root_volume_size}"
  }

  # docker
  ebs_block_device {
    device_name = "/dev/xvdcz"
    volume_type = "gp2"
    volume_size = "${var.ecs_docker_volume_size}"
  }

  lifecycle {
    create_before_destroy = true
  }

  name = "${format("%s-%s-launch-configuratian", var.ecs_base_cluster_name, var.environment)}"
}

resource "aws_ecs_cluster" "main" {
  name = "${var.ecs_base_cluster_name}-${var.environment}"
}

resource "aws_autoscaling_group" "main" {
  name                 = "${var.ecs_base_cluster_name}-${var.environment}-asg"
  vpc_zone_identifier  = ["${aws_subnet.internal.*.id}"]
  min_size             = "${var.ecs_min_size}"
  max_size             = "${var.ecs_max_size}"
  desired_capacity     = "${var.ecs_desired_capacity}"
  launch_configuration = "${aws_launch_configuration.ecs_instance.name}"

  depends_on = [
    "aws_ecs_cluster.main",
  ]

  tags = [
    {
      key                 = "Name"
      value               = "${var.ecs_base_cluster_name}-${var.environment}-instance"
      propagate_at_launch = true
    },
    {
      key                 = "Environment"
      value               = "${var.environment}"
      propagate_at_launch = true
    },
  ]
}
