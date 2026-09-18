
resource "aws_ecs_cluster" "name" {
  name = "ecs"

  depends_on = [aws_iam_role.ecs_role]

  setting {
    name  = "containerInsights"
    value = "enhanced"
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    "Name" = "ecs_cluster"
  }
}

resource "aws_ecs_cluster_capacity_providers" "name" {
  cluster_name       = aws_ecs_cluster.name.name
  capacity_providers = [aws_ecs_capacity_provider.name.name]

  # default_capacity_provider_strategy {
  #   base = 2
  #   weight = 100
  #   capacity_provider = "EC2"
  # }
}

resource "aws_ecs_capacity_provider" "name" {
  name = "my_ecs"

  auto_scaling_group_provider {
    auto_scaling_group_arn         = aws_autoscaling_group.name.arn
    managed_termination_protection = "ENABLED"

    managed_scaling {
      maximum_scaling_step_size = 100
      minimum_scaling_step_size = 1
      status                    = "ENABLED"
      target_capacity           = 30
      instance_warmup_period    = 10
    }
  }
}

resource "aws_ecs_service" "frontend" {
  name = "frontend_svc"
  # iam_role = aws_iam_role.ecs_svc_role.arn
  depends_on                         = [aws_iam_role.ecs_svc_role]
  cluster                            = aws_ecs_cluster.name.id
  task_definition                    = aws_ecs_task_definition.front.arn
  desired_count                      = 1
  deployment_minimum_healthy_percent = "50"
  deployment_maximum_percent         = "200"
  launch_type                        = "EC2"
  # ordered_placement_strategy {
  #   type = "spread"
  #   field = "attribute:ecs.availability-zone"
  # }

  # network_configuration {
  #   subnets         = aws_subnet.private_app[*].id
  #   security_groups = [aws_security_group.ecs_sg.id]
  # }
  ordered_placement_strategy {
    type  = "binpack"
    field = "memory"
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.front.arn
    container_name   = "front"
    container_port   = "80"
  }

  lifecycle {
    ignore_changes = [desired_count]
  }
  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }
  # ordered_placement_strategy {
  #   type   = "spread"
  #   field = "attribute:ecs.availability-zone"
  # }
}

resource "aws_ecs_service" "back" {
  name = "backend_svc"
  # iam_role = aws_iam_role.ecs_svc_role.arn
  depends_on                         = [aws_iam_role.ecs_svc_role]
  cluster                            = aws_ecs_cluster.name.id
  task_definition                    = aws_ecs_task_definition.back.arn
  desired_count                      = 1
  deployment_minimum_healthy_percent = "50"
  deployment_maximum_percent         = "200"

  # ordered_placement_strategy {
  #   type = "spread"
  #   field = "attribute:ecs.availability-zone"
  # }

  # network_configuration {
  #   subnets         = aws_subnet.private_app[*].id
  #   security_groups = [aws_security_group.ecs_sg.id]
  # }
  ordered_placement_strategy {
    type  = "binpack"
    field = "memory"
  }
  capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.name.name
    weight            = 100
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.back.arn
    container_name   = "back"
    container_port   = "3333"
  }
  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }
  lifecycle {
    ignore_changes = [desired_count]
  }

}

resource "aws_ecs_task_definition" "front" {
  family = "front_task_definition"
  # task_role_arn = aws_iam_role.ecs_task_iam_role.arn

  execution_role_arn = aws_iam_role.ecs_task_iam_role.arn
  network_mode       = "bridge"
  container_definitions = jsonencode([
    {
      name      = "front"
      image     = "650251731474.dkr.ecr.ap-northeast-2.amazonaws.com/frontend:latest"
      cpu       = 256
      memory    = 512
      essential = true

      portMappings = [
        {
          containerPort = 80
          hostPort      = 0
          protocol      = "tcp"
        }
      ]
    }
  ])

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }
}

resource "aws_ecs_task_definition" "back" {
  family = "back_task_definition"
  # task_role_arn = aws_iam_role.ecs_task_iam_role.arn
  execution_role_arn = aws_iam_role.ecs_task_iam_role.arn
  network_mode       = "bridge"
  cpu                = 256
  container_definitions = jsonencode([
    {
      name      = "back"
      image     = "650251731474.dkr.ecr.ap-northeast-2.amazonaws.com/backend:latest"
      cpu       = 256
      memory    = 512
      essential = true
      portMappings = [
        {
          containerPort = 3333
          hostPort      = 3333
          protocol      = "tcp"
        }
      ]
    }
  ])

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }
}

resource "aws_appautoscaling_target" "ecs_target" {
  max_capacity       = 10
  min_capacity       = 1
  resource_id        = "service/${aws_ecs_cluster.name.name}/${aws_ecs_service.frontend.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "ecs_cpu_policy" {
  name               = "CPUTargetTrackingScaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace

  target_tracking_scaling_policy_configuration {
    target_value       = 50
    scale_in_cooldown  = 30
    scale_out_cooldown = 30
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
  }
}

resource "aws_appautoscaling_policy" "ecs_memory_policy" {
  name               = "MemoryTargetTrackingScaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace
  target_tracking_scaling_policy_configuration {
    target_value       = 50
    scale_in_cooldown  = 30
    scale_out_cooldown = 30
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }
  }
}

resource "aws_appautoscaling_target" "ecs_target_2" {
  max_capacity       = 10
  min_capacity       = 1
  resource_id        = "service/${aws_ecs_cluster.name.name}/${aws_ecs_service.back.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "ecs_cpu_policy_2" {
  name               = "CPUTargetTrackingScaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_target_2.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target_2.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target_2.service_namespace

  target_tracking_scaling_policy_configuration {
    target_value       = 50
    scale_in_cooldown  = 30
    scale_out_cooldown = 30

    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
  }
}

resource "aws_appautoscaling_policy" "ecs_memory_policy_2" {
  name               = "MemoryTargetTrackingScaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_target_2.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target_2.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target_2.service_namespace
  target_tracking_scaling_policy_configuration {
    target_value       = 50
    scale_in_cooldown  = 30
    scale_out_cooldown = 30
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }
  }
}
