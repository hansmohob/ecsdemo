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
      image                  = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.Region}.amazonaws.com/web:${var.ImageTag}"
      cpu                    = 256
      memory                 = 512
      essential              = true
      readonlyRootFilesystem = true
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
      image                  = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.Region}.amazonaws.com/cats:${var.ImageTag}"
      cpu                    = 256
      memory                 = 512
      essential              = true
      readonlyRootFilesystem = true
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
      image                  = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.Region}.amazonaws.com/dogs:${var.ImageTag}"
      cpu                    = 256
      memory                 = 512
      essential              = true
      readonlyRootFilesystem = true
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
    target_group_arn = aws_lb_target_group.catsanddogs.arn
    container_name   = "web"
    container_port   = 80
  }

  tags = {
    Name  = format("%s%s%s%s", var.Region, "iar", var.EnvCode, "web")
    rtype = "ecsservice"
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
    target_group_arn = aws_lb_target_group.catsanddogs.arn
    container_name   = "cats"
    container_port   = 80
  }

  tags = {
    Name  = format("%s%s%s%s", var.Region, "iar", var.EnvCode, "cats")
    rtype = "ecsservice"
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
    target_group_arn = aws_lb_target_group.catsanddogs.arn
    container_name   = "dogs"
    container_port   = 80
  }

  tags = {
    Name  = format("%s%s%s%s", var.Region, "iar", var.EnvCode, "dogs")
    rtype = "ecsservice"
  }
}