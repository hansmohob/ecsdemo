# Create ECR repositories
data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "catsanddogskms" {
  statement {
    # https://docs.aws.amazon.com/kms/latest/developerguide/key-policy-overview.html
    sid    = "Enable IAM User Permissions"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
    actions = [
      "kms*"
    ]
    resources = [
      "*"
    ]
  }
  statement {
    # https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/encrypt-log-data-kms.html
    sid    = "Allow Cloudwatch access to KMS Key"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["logs.${var.Region}.amazonaws.com"]
    }
    actions = [
      "kms:Encrypt*",
      "kms:Decrypt*",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:Describe*"
    ]
    resources = [
      "*"
    ]
    condition {
      test     = "ArnLike"
      variable = "kms:EncryptionContext:aws:logs:arn"
      values = [
        "arn:aws:logs:${var.Region}:${data.aws_caller_identity.current.account_id}:*"
      ]
    }
  }
}

# Create KMS key for solution
resource "aws_kms_key" "catsanddogs" {
  description             = "KMS key to secure various aspects of an example Microsoft .NET web application"
  deletion_window_in_days = 7
  enable_key_rotation     = true
  policy                  = data.aws_iam_policy_document.catsanddogskms.json

  tags = {
    Name         = format("%s%s%s%s", var.PrefixCode, "kms", var.EnvCode, "catsanddogs")
    resourcetype = "security"
    codeblock    = "ecscluster"
  }
}

# Create KMS Alias. Only used in this context to provide a friendly display name
resource "aws_kms_alias" "catsanddogs" {
  name          = format("%s%s%s", "alias/", var.PrefixCode, "catsanddogs")
  target_key_id = aws_kms_key.catsanddogs.key_id
}


# Create Amazon ECR repository for web
resource "aws_ecr_repository" "web" {
  name                 = format("%s%s", var.PrefixCode, "-catsanddogs-web")
  image_tag_mutability = "MUTABLE"
  force_delete         = true

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "KMS"
    kms_key         = aws_kms_key.catsanddogs.arn
  }

  tags = {
    Name         = format("%s%s%s%s", var.PrefixCode, "ecs", var.EnvCode, "web")
    resourcetype = "compute"
    codeblock    = "ecscluster"
  }
}

# Create ECR lifecycle policy to delete untagged images after 1 day
resource "aws_ecr_lifecycle_policy" "web" {
  repository = aws_ecr_repository.web.name

  policy = <<EOF
{
  "rules": [
    {
      "rulePriority": 1,
      "description": "Delete untagged images after one day",
      "selection": {
        "tagStatus": "untagged",
        "countType": "sinceImagePushed",
        "countUnit": "days",
        "countNumber": 1
      },
      "action": {
        "type": "expire"
      }
    }
  ]
}
EOF
}

# Create Amazon ECR repository for cats
resource "aws_ecr_repository" "cats" {
  name                 = format("%s%s", var.PrefixCode, "-catsanddogs-cats")
  image_tag_mutability = "MUTABLE"
  force_delete         = true

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "KMS"
    kms_key         = aws_kms_key.catsanddogs.arn
  }

  tags = {
    Name         = format("%s%s%s%s", var.PrefixCode, "ecs", var.EnvCode, "cats")
    resourcetype = "compute"
    codeblock    = "ecscluster"
  }
}

# Create ECR lifecycle policy to delete untagged images after 1 day
resource "aws_ecr_lifecycle_policy" "cats" {
  repository = aws_ecr_repository.cats.name

  policy = <<EOF
{
  "rules": [
    {
      "rulePriority": 1,
      "description": "Delete untagged images after one day",
      "selection": {
        "tagStatus": "untagged",
        "countType": "sinceImagePushed",
        "countUnit": "days",
        "countNumber": 1
      },
      "action": {
        "type": "expire"
      }
    }
  ]
}
EOF
}

# Create Amazon ECR repository for dogs
resource "aws_ecr_repository" "dogs" {
  name                 = format("%s%s", var.PrefixCode, "-catsanddogs-dogs")
  image_tag_mutability = "MUTABLE"
  force_delete         = true

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "KMS"
    kms_key         = aws_kms_key.catsanddogs.arn
  }

  tags = {
    Name         = format("%s%s%s%s", var.PrefixCode, "ecs", var.EnvCode, "dogs")
    resourcetype = "compute"
    codeblock    = "ecscluster"
  }
}

# Create ECR lifecycle policy to delete untagged images after 1 day
resource "aws_ecr_lifecycle_policy" "dogs" {
  repository = aws_ecr_repository.dogs.name

  policy = <<EOF
{
  "rules": [
    {
      "rulePriority": 1,
      "description": "Delete untagged images after one day",
      "selection": {
        "tagStatus": "untagged",
        "countType": "sinceImagePushed",
        "countUnit": "days",
        "countNumber": 1
      },
      "action": {
        "type": "expire"
      }
    }
  ]
}
EOF
}

# Outputs for Codebuild
output "web_repository_url" {
  description = "The URL of the web repository"
  value       = aws_ecr_repository.web.repository_url
}

output "cats_repository_url" {
  description = "The URL of the cats repository"
  value       = aws_ecr_repository.cats.repository_url
}

output "dogs_repository_url" {
  description = "The URL of the dogs repository"
  value       = aws_ecr_repository.dogs.repository_url
}