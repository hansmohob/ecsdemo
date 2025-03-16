### Create Amazon ECS task definition and service

# Create web task definition
resource "aws_ecs_task_definition" "web" {
  family                   = format("%s%s%s%s", var.PrefixCode, "ect", var.EnvCode, "web")
  requires_compatibilities = ["FARGATE"]
  cpu                      = 1024
  memory                   = 2048
  network_mode             = "awsvpc"
  execution_role_arn       = aws_iam_role.ecstaskexec.arn

  container_definitions = jsonencode([
    {
      name                   = "web"
      image                  = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.Region}.amazonaws.com/catsanddogs-web:${var.ImageTag}"
      cpu                    = 256
      memory                 = 512
      essential              = true
      readonlyRootFilesystem = false # this is bad
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
          protocol      = "tcp"
        }
      ]
      logconfiguration = {
        logDriver = "awslogs",
        options = {
          awslogs-group         = "${aws_cloudwatch_log_group.catsanddogs.name}",
          awslogs-region        = "${var.Region}",
          awslogs-stream-prefix = "awslogs-"
        }
      }
    }
  ])
}

# Create cats task definition
resource "aws_ecs_task_definition" "cats" {
  family                   = format("%s%s%s%s", var.PrefixCode, "ect", var.EnvCode, "cats")
  requires_compatibilities = ["FARGATE"]
  cpu                      = 1024
  memory                   = 2048
  network_mode             = "awsvpc"
  execution_role_arn       = aws_iam_role.ecstaskexec.arn

  container_definitions = jsonencode([
    {
      name                   = "cats"
      image                  = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.Region}.amazonaws.com/catsanddogs-cats:${var.ImageTag}"
      cpu                    = 256
      memory                 = 512
      essential              = true
      readonlyRootFilesystem = false # this is bad
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
          protocol      = "tcp"
        }
      ]
      logconfiguration = {
        logDriver = "awslogs",
        options = {
          awslogs-group         = "${aws_cloudwatch_log_group.catsanddogs.name}",
          awslogs-region        = "${var.Region}",
          awslogs-stream-prefix = "awslogs-"
        }
      }
    }
  ])
}

# Create dogs task definition
resource "aws_ecs_task_definition" "dogs" {
  family                   = format("%s%s%s%s", var.PrefixCode, "ect", var.EnvCode, "dogs")
  requires_compatibilities = ["FARGATE"]
  cpu                      = 1024
  memory                   = 2048
  network_mode             = "awsvpc"
  execution_role_arn       = aws_iam_role.ecstaskexec.arn

  container_definitions = jsonencode([
    {
      name                   = "dogs"
      image                  = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.Region}.amazonaws.com/catsanddogs-dogs:${var.ImageTag}"
      cpu                    = 256
      memory                 = 512
      essential              = true
      readonlyRootFilesystem = false # this is bad
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
          protocol      = "tcp"
        }
      ]
      logconfiguration = {
        logDriver = "awslogs",
        options = {
          awslogs-group         = "${aws_cloudwatch_log_group.catsanddogs.name}",
          awslogs-region        = "${var.Region}",
          awslogs-stream-prefix = "awslogs-"
        }
      }
    }
  ])
}

# Create web task service
resource "aws_ecs_service" "web" {
  name            = format("%s%s%s%s", var.Region, "iar", var.EnvCode, "web")
  cluster         = aws_ecs_cluster.catsanddogs.id
  task_definition = aws_ecs_task_definition.web.arn
  launch_type     = "FARGATE"
  desired_count   = 2
  propagate_tags  = "TASK_DEFINITION"


  network_configuration {
    subnets         = [aws_subnet.priv_subnet_01.id, aws_subnet.priv_subnet_02.id]
    security_groups = [aws_security_group.app01.id]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.web.arn
    container_name   = "web"
    container_port   = 80
  }

  tags = {
    Name  = format("%s%s%s%s", var.Region, "iar", var.EnvCode, "web")
    rtype = "ecsservice"
  }
}

resource "aws_appautoscaling_target" "web" {
  max_capacity       = 4
  min_capacity       = 2
  resource_id        = "service/${aws_ecs_cluster.catsanddogs.name}/${aws_ecs_service.web.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "web_cpu" {
  name               = "web-cpu"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.web.resource_id
  scalable_dimension = aws_appautoscaling_target.web.scalable_dimension
  service_namespace  = aws_appautoscaling_target.web.service_namespace

  target_tracking_scaling_policy_configuration {
    target_value = 70.0
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
  }
}

# Create cats task service
resource "aws_ecs_service" "cats" {
  name            = format("%s%s%s%s", var.Region, "iar", var.EnvCode, "cats")
  cluster         = aws_ecs_cluster.catsanddogs.id
  task_definition = aws_ecs_task_definition.cats.arn
  launch_type     = "FARGATE"
  desired_count   = 2
  propagate_tags  = "TASK_DEFINITION"


  network_configuration {
    subnets         = [aws_subnet.priv_subnet_01.id, aws_subnet.priv_subnet_02.id]
    security_groups = [aws_security_group.app01.id]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.cats.arn
    container_name   = "cats"
    container_port   = 80
  }

  tags = {
    Name  = format("%s%s%s%s", var.Region, "iar", var.EnvCode, "cats")
    rtype = "ecsservice"
  }
}

resource "aws_appautoscaling_target" "cats" {
  max_capacity       = 4
  min_capacity       = 2
  resource_id        = "service/${aws_ecs_cluster.catsanddogs.name}/${aws_ecs_service.cats.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "cats_cpu" {
  name               = "cats-cpu"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.cats.resource_id
  scalable_dimension = aws_appautoscaling_target.cats.scalable_dimension
  service_namespace  = aws_appautoscaling_target.cats.service_namespace

  target_tracking_scaling_policy_configuration {
    target_value = 70.0
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
  }
}

# Create dogs task service
resource "aws_ecs_service" "dogs" {
  name            = format("%s%s%s%s", var.Region, "iar", var.EnvCode, "dogs")
  cluster         = aws_ecs_cluster.catsanddogs.id
  task_definition = aws_ecs_task_definition.dogs.arn
  launch_type     = "FARGATE"
  desired_count   = 2
  propagate_tags  = "TASK_DEFINITION"


  network_configuration {
    subnets         = [aws_subnet.priv_subnet_01.id, aws_subnet.priv_subnet_02.id]
    security_groups = [aws_security_group.app01.id]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.dogs.arn
    container_name   = "dogs"
    container_port   = 80
  }

  tags = {
    Name  = format("%s%s%s%s", var.Region, "iar", var.EnvCode, "dogs")
    rtype = "ecsservice"
  }
}

resource "aws_appautoscaling_target" "dogs" {
  max_capacity       = 4
  min_capacity       = 2
  resource_id        = "service/${aws_ecs_cluster.catsanddogs.name}/${aws_ecs_service.dogs.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "dogs_cpu" {
  name               = "dogs-cpu"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.dogs.resource_id
  scalable_dimension = aws_appautoscaling_target.dogs.scalable_dimension
  service_namespace  = aws_appautoscaling_target.dogs.service_namespace

  target_tracking_scaling_policy_configuration {
    target_value = 70.0
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
  }
}