### Create AWS network resources

# Create Amazon VPC
resource "aws_vpc" "vpc_01" {
  cidr_block       = format("%s.0.0/16", var.VpcCidr)
  instance_tenancy = "default"

  tags = {
    Name         = format("%s%s%s%s", var.PrefixCode, "vpc", var.EnvCode, "01")
    resourcetype = "network"
    codeblock    = "network-3tier"
  }
}

# IAM role for VPC flow logging
resource "aws_iam_role" "vpclogging" {
  name = format("%s%s%s%s", var.PrefixCode, "iar", var.EnvCode, "vpclogging")
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "vpc-flow-logs.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name  = format("%s%s%s%s", var.Region, "iar", var.EnvCode, "vpclogging")
    rtype = "security"
  }
}

resource "aws_iam_role_policy" "vpclogging" {
  name = format("%s%s%s%s", var.Region, "irp", var.EnvCode, "vpclogging")
  role = aws_iam_role.vpclogging.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams",
        ]
        Effect   = "Allow"
        Resource = ["arn:aws:logs:*:*:*"]
      }
    ]
  })
}

# Create CloudWatch log group for VPC
resource "aws_cloudwatch_log_group" "vpc_01" {
  name              = format("%s%s%s%s", var.PrefixCode, "cwl", var.EnvCode, "vpc01flow")
  retention_in_days = 90
  kms_key_id        = aws_kms_key.helloworld.arn

  tags = {
    Name         = format("%s%s%s%s", var.PrefixCode, "cwl", var.EnvCode, "vpc01flow")
    resourcetype = "monitor"
    codeblock    = "network"
  }
}

# Configure VPC flow logs
resource "aws_flow_log" "vpc_01" {
  iam_role_arn    = aws_iam_role.vpclogging.arn
  log_destination = aws_cloudwatch_log_group.vpc_01.arn
  traffic_type    = "ALL"
  vpc_id          = aws_vpc.vpc_01.id
}

# Create Internet Gateway
resource "aws_internet_gateway" "internet_gateway_01" {
  vpc_id = aws_vpc.vpc_01.id

  tags = {
    Name         = format("%s%s%s%s", var.PrefixCode, "igw", var.EnvCode, "01")
    resourcetype = "network"
    codeblock    = "network-3tier"

  }
}

# Create Subnets
resource "aws_subnet" "pub_subnet_01" {
  vpc_id            = aws_vpc.vpc_01.id
  cidr_block        = format("%s.1.0/24", var.VpcCidr)
  availability_zone = var.Az01

  tags = {
    Name         = format("%s%s%s%s%s", var.PrefixCode, "sbn", "pb", var.EnvCode, "01")
    resourcetype = "network"
    codeblock    = "network-3tier"
  }
}

resource "aws_subnet" "pub_subnet_02" {
  vpc_id            = aws_vpc.vpc_01.id
  cidr_block        = format("%s.2.0/24", var.VpcCidr)
  availability_zone = var.Az02

  tags = {
    Name         = format("%s%s%s%s%s", var.PrefixCode, "sbn", "pb", var.EnvCode, "02")
    resourcetype = "network"
    codeblock    = "network-3tier"
  }
}

resource "aws_subnet" "priv_subnet_01" {
  vpc_id            = aws_vpc.vpc_01.id
  cidr_block        = format("%s.3.0/24", var.VpcCidr)
  availability_zone = var.Az01

  tags = {
    Name         = format("%s%s%s%s%s", var.PrefixCode, "sbn", "pv", var.EnvCode, "01")
    resourcetype = "network"
    codeblock    = "network-3tier"
  }
}

resource "aws_subnet" "priv_subnet_02" {
  vpc_id            = aws_vpc.vpc_01.id
  cidr_block        = format("%s.4.0/24", var.VpcCidr)
  availability_zone = var.Az02

  tags = {
    Name         = format("%s%s%s%s%s", var.PrefixCode, "sbn", "pv", var.EnvCode, "02")
    resourcetype = "network"
    codeblock    = "network-3tier"
  }
}

# Create NAT Gateway
resource "aws_eip" "eip_nat_01" {
  depends_on = [aws_internet_gateway.internet_gateway_01]

  tags = {
    Name         = format("%s%s%s%s", var.PrefixCode, "eip", var.EnvCode, "01")
    resourcetype = "network"
    codeblock    = "network-3tier"
  }
}

resource "aws_eip" "eip_nat_02" {
  depends_on = [aws_internet_gateway.internet_gateway_01]

  tags = {
    Name         = format("%s%s%s%s", var.PrefixCode, "eip", var.EnvCode, "02")
    resourcetype = "network"
    codeblock    = "network-3tier"
  }
}

resource "aws_nat_gateway" "nat_gateway_01" {
  depends_on = [aws_internet_gateway.internet_gateway_01]

  allocation_id = aws_eip.eip_nat_01.id
  subnet_id     = aws_subnet.pub_subnet_01.id

  tags = {
    Name         = format("%s%s%s%s", var.PrefixCode, "ngw", var.EnvCode, "01")
    resourcetype = "network"
    codeblock    = "network-3tier"
  }
}

resource "aws_nat_gateway" "nat_gateway_02" {
  depends_on = [aws_internet_gateway.internet_gateway_01]

  allocation_id = aws_eip.eip_nat_02.id
  subnet_id     = aws_subnet.pub_subnet_02.id

  tags = {
    Name         = format("%s%s%s%s", var.PrefixCode, "ngw", var.EnvCode, "02")
    resourcetype = "network"
    codeblock    = "network-3tier"
  }
}

# Create Route Tables
resource "aws_route_table" "pub_01" {
  vpc_id = aws_vpc.vpc_01.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway_01.id
  }

  tags = {
    Name         = format("%s%s%s%s%s", var.PrefixCode, "rtt", "pb", var.EnvCode, "01")
    resourcetype = "network"
    codeblock    = "network-3tier"
  }
}

resource "aws_route_table_association" "pub_01" {
  subnet_id      = aws_subnet.pub_subnet_01.id
  route_table_id = aws_route_table.pub_01.id
}

resource "aws_route_table_association" "pub_02" {
  subnet_id      = aws_subnet.pub_subnet_02.id
  route_table_id = aws_route_table.pub_01.id
}

resource "aws_route_table" "priv_01" {
  vpc_id = aws_vpc.vpc_01.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway_01.id
  }

  tags = {
    Name         = format("%s%s%s%s%s", var.PrefixCode, "rtt", "pv", var.EnvCode, "01")
    resourcetype = "network"
    codeblock    = "network-3tier"
  }
}

resource "aws_route_table" "priv_02" {
  vpc_id = aws_vpc.vpc_01.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway_02.id
  }

  tags = {
    Name         = format("%s%s%s%s%s", var.PrefixCode, "rtt", "pv", var.EnvCode, "02")
    resourcetype = "network"
    codeblock    = "network-3tier"
  }
}

resource "aws_route_table_association" "pv_01" {
  subnet_id      = aws_subnet.priv_subnet_01.id
  route_table_id = aws_route_table.priv_01.id
}

resource "aws_route_table_association" "pv_02" {
  subnet_id      = aws_subnet.priv_subnet_02.id
  route_table_id = aws_route_table.priv_02.id
}

# Create Security Groups
resource "aws_security_group" "web01" {
  name        = format("%s%s%s%s", var.PrefixCode, "scg", var.EnvCode, "web01")
  description = "Web Security Group"
  vpc_id      = aws_vpc.vpc_01.id

  ingress {
    description = "Web Inbound"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.PublicIP]
  }

  egress {
    description = "Web Outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name         = format("%s%s%s%s", var.PrefixCode, "scg", var.EnvCode, "web01")
    resourcetype = "security"
    codeblock    = "network-3tier"
  }
}

resource "aws_security_group" "app01" {
  name        = format("%s%s%s%s", var.PrefixCode, "scg", var.EnvCode, "app01")
  description = " Application Security Group"
  vpc_id      = aws_vpc.vpc_01.id

  ingress {
    description     = "Application Inbound"
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [aws_security_group.web01.id]
    self            = true
  }

  egress {
    description = "Application Outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name         = format("%s%s%s%s", var.PrefixCode, "scg", var.EnvCode, "app01")
    resourcetype = "security"
    codeblock    = "network-3tier"
  }
}

# Create Application Load Balancer
# WARNING: Consider implementing AWS WAFv2 in front of an Application Load Balancer for production environments
resource "aws_lb" "helloworld" {
  name                       = format("%s%s%s%s", var.PrefixCode, "alb", var.EnvCode, "helloworld")
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.web01.id]
  subnets                    = [aws_subnet.pub_subnet_01.id, aws_subnet.pub_subnet_02.id]
  drop_invalid_header_fields = true

  access_logs {
    bucket  = aws_s3_bucket.alblogs.id
    prefix  = "albaccesslogs"
    enabled = true
  }

  tags = {
    Name  = format("%s%s%s%s", var.Region, "alb", var.EnvCode, "helloworld")
    rtype = "network"
  }
}

# Output ALB DNS name for GitHub Actions job output
output "helloworld_alb_dns_name" {
  value = aws_lb.helloworld.dns_name
}

# Create ALB listener
# WARNING: Consider changing port to 443 and protocol to HTTPS for production environments 
resource "aws_lb_listener" "helloworld" {
  load_balancer_arn = aws_lb.helloworld.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.helloworld.arn
  }

  tags = {
    Name  = format("%s%s%s%s", var.Region, "lbl", var.EnvCode, "helloworld")
    rtype = "network"
  }
}

# Define ALB Target Group
# WARNING: Lifecyle and name_prefix added for testing. Issue discussed here https://github.com/hashicorp/terraform-provider-aws/issues/16889
resource "aws_lb_target_group" "helloworld" {
  name_prefix                   = "hello-"
  port                          = 80
  protocol                      = "HTTP"
  target_type                   = "ip"
  vpc_id                        = aws_vpc.vpc_01.id
  load_balancing_algorithm_type = "round_robin"

  health_check {
    path    = "/"
    matcher = "200"
  }

  stickiness {
    enabled         = true
    type            = "lb_cookie"
    cookie_duration = 86400
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name  = format("%s%s%s%s", var.Region, "lbt", var.EnvCode, "helloworld")
    rtype = "network"
  }
}