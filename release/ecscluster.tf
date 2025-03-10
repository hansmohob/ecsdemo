### Create Amazon ECS Cluster

# Create CloudWatch log group for ECS logs 
resource "aws_cloudwatch_log_group" "ecscluster" {
  name              = format("%s%s%s%s", var.PrefixCode, "cwl", var.EnvCode, "ecscluster")
  retention_in_days = 90
  kms_key_id        = aws_kms_key.catsanddogs.arn

  tags = {
    Name         = format("%s%s%s%s", var.PrefixCode, "cwl", var.EnvCode, "ecscluster")
    resourcetype = "monitor"
    codeblock    = "ecscluster"
  }
}

# Create CloudWatch log group for Application logs
resource "aws_cloudwatch_log_group" "catsanddogs" {
  name              = format("%s%s%s%s", var.PrefixCode, "cwl", var.EnvCode, "catsanddogs")
  retention_in_days = 30
  kms_key_id        = aws_kms_key.catsanddogs.arn

  tags = {
    Name         = format("%s%s%s%s", var.PrefixCode, "cwl", var.EnvCode, "catsanddogs")
    resourcetype = "monitor"
    codeblock    = "ecscluster"
  }
}

# Create Amazon ECS cluster 
resource "aws_ecs_cluster" "catsanddogs" {
  name = format("%s%s%s%s", var.PrefixCode, "ecs", var.EnvCode, "catsanddogs")

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  configuration {
    execute_command_configuration {
      kms_key_id = aws_kms_key.catsanddogs.arn
      logging    = "OVERRIDE"

      log_configuration {
        cloud_watch_encryption_enabled = true
        cloud_watch_log_group_name     = aws_cloudwatch_log_group.ecscluster.name
      }
    }
  }

  tags = {
    Name         = format("%s%s%s%s", var.PrefixCode, "ecs", var.EnvCode, "catsanddogs")
    resourcetype = "storage"
    codeblock    = "ecscluster"
  }
}

# Establish IAM Role with permissions for Amazon ECS to access Amazon ECR for image pulling and CloudWatch for logging
resource "aws_iam_role" "ecstaskexec" {
  name = format("%s%s%s%s", var.PrefixCode, "iar", var.EnvCode, "ecstaskexec")
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name  = format("%s%s%s%s", var.Region, "iar", var.EnvCode, "ecstaskexec")
    rtype = "security"
  }
}

resource "aws_iam_role_policy" "ecstaskexec" {
  name = format("%s%s%s%s", var.Region, "irp", var.EnvCode, "ecstaskexec")
  role = aws_iam_role.ecstaskexec.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        # https://docs.aws.amazon.com/AmazonECR/latest/userguide/security_iam_id-based-policy-examples.html
        Action = [
          "ecr:GetAuthorizationToken"
        ]
        Effect   = "Allow"
        Resource = ["*"]
      },
      {
        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage"
        ]
        Effect   = "Allow"
        Resource = [
          "${aws_ecr_repository.web.arn}",
          "${aws_ecr_repository.cats.arn}",
          "${aws_ecr_repository.dogs.arn}",
        ]
      },
      {
        # https://docs.aws.amazon.com/AmazonECS/latest/developerguide/instance_IAM_role.html#cwl_iam_policy
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams"
        ]
        Effect   = "Allow"
        Resource = ["arn:aws:logs:*:*:*"]
      }
    ]
  })
}