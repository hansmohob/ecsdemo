### Create Amazon ECS task definition and service

# Create Amazon ECS task definition
resource "aws_ecs_task_definition" "helloworld" {
  family                   = format("%s%s%s%s", var.PrefixCode, "ect", var.EnvCode, "helloworld")
  requires_compatibilities = ["FARGATE"]
  cpu                      = 1024
  memory                   = 2048
  network_mode             = "awsvpc"
  execution_role_arn       = aws_iam_role.ecstaskexec.arn

  container_definitions = jsonencode([
    {
      name                   = "helloworld"
      image                  = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.Region}.amazonaws.com/${var.ECRRepo}:${var.ImageTag}"
      cpu                    = 256
      memory                 = 512
      essential              = true
      readonlyRootFilesystem = true
      portMappings = [
        {
          containerPort = 8080
          hostPort      = 8080
          protocol      = "tcp"
        }
      ]
      logconfiguration = {
        logDriver = "awslogs",
        options = {
          awslogs-group         = "${aws_cloudwatch_log_group.helloworld.name}",
          awslogs-region        = "${var.Region}",
          awslogs-stream-prefix = "awslogs-"
        }
      }
    }
  ])
}

# Create Amazon ECS task service
resource "aws_ecs_service" "helloworld" {
  name            = format("%s%s%s%s", var.Region, "iar", var.EnvCode, "svchelloworld")
  cluster         = aws_ecs_cluster.helloworld.id
  task_definition = aws_ecs_task_definition.helloworld.arn
  launch_type     = "FARGATE"
  desired_count   = 2
  propagate_tags  = "TASK_DEFINITION"


  network_configuration {
    subnets         = [aws_subnet.priv_subnet_01.id, aws_subnet.priv_subnet_02.id]
    security_groups = [aws_security_group.app01.id]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.helloworld.arn
    container_name   = "helloworld"
    container_port   = 8080
  }

  tags = {
    Name  = format("%s%s%s%s", var.Region, "iar", var.EnvCode, "svchelloworld")
    rtype = "ecsservice"
  }
}