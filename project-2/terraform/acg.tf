locals {
  key_pair_name = "myKey"
}

resource "aws_launch_template" "name" {
  name_prefix   = "ecs_container"
  image_id      = data.aws_ami.amazon_linux_2.id
  instance_type = "t3.small"
  key_name      = local.key_pair_name
  user_data = base64encode(<<-EOF
      #!/bin/bash
      echo ECS_CLUSTER=${aws_ecs_cluster.name.name} >> /etc/ecs/ecs.config;
    EOF
  )
  vpc_security_group_ids = [aws_security_group.ecs_sg.id]

  iam_instance_profile {
    arn = aws_iam_instance_profile.ec2_instance_role_profile.arn
  }
  monitoring {
    enabled = true
  }

  tags = {
    "Name" = "ecs_container"
  }
}

resource "aws_autoscaling_group" "name" {
  name             = "ecs_asg"
  desired_capacity = 1
  max_size         = 10
  min_size         = 1


  vpc_zone_identifier = aws_subnet.private_app.*.id
  #   health_check_type = "EC2"
  protect_from_scale_in = true

  enabled_metrics = [
    "GroupMinSize",
    "GroupMaxSize",
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupPendingInstances",
    "GroupStandbyInstances",
    "GroupTerminatingInstances",
    "GroupTotalInstances"
  ]

  launch_template {
    id      = aws_launch_template.name.id
    version = "$Latest"
  }

  instance_refresh {
    strategy = "Rolling"
  }

  lifecycle {
    create_before_destroy = true
  }

  tag {
    key                 = "AmazonECSManaged"
    value               = true
    propagate_at_launch = true
  }
}
