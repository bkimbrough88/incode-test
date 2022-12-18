#############################################
## CertManager Resources
#############################################
resource "aws_acm_certificate" "cert" {
  count = var.use_tls ? 1 : 0

  domain_name       = var.domain_name
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

#############################################
## IAM Resources
#############################################
resource "aws_iam_role" "task" {
  name               = var.name
  assume_role_policy = var.assume_role_policy
}

resource "aws_iam_policy" "task" {
  name   = var.name
  policy = data.aws_iam_policy_document.task_policy.json
}

#############################################
## ECR Resources
#############################################
resource "aws_ecr_repository" "repo" {
  name         = var.container_image
  force_delete = true   # just for easy cleanup of environment

  image_scanning_configuration {
    scan_on_push = true
  }
}

#############################################
## ECS Resources
#############################################
resource "aws_ecs_task_definition" "task" {
  container_definitions    = local.container_definition
  cpu                      = var.cpu
  family                   = var.name
  execution_role_arn       = var.execution_role_arn
  memory                   = var.memory
  network_mode             = "awsvpc"
  requires_compatibilities = ["EC2"]
  task_role_arn            = aws_iam_role.task.arn
}

resource "aws_ecs_service" "service" {
  depends_on = [aws_lb_target_group.lb, aws_security_group.task]

  name                       = var.name
  cluster                    = var.cluster_id
  desired_count              = var.replicas
  deployment_maximum_percent = var.deployment_max_percent
  task_definition            = aws_ecs_task_definition.task.arn
  propagate_tags             = "SERVICE"

  load_balancer {
    container_name   = var.container_name
    container_port   = local.port
    target_group_arn = aws_lb_target_group.lb.arn
  }

  network_configuration {
    subnets         = var.subnets
    security_groups = [aws_security_group.task.id]
  }

  ordered_placement_strategy {
    type  = "binpack"
    field = "cpu"
  }

  capacity_provider_strategy {
    capacity_provider = var.capacity_provider_name
    weight            = 100
  }

  deployment_controller {
    type = "ECS"
  }
}

#############################################
## LoadBalancer Resources
#############################################
locals {
  lb_sg_cidr = var.internal ? data.aws_vpc.vpc.cidr_block : "0.0.0.0/0"
  cert_arn   = var.use_tls ? aws_acm_certificate.cert[0].arn : null
  port       = var.use_tls ? 443 : 80
  protocol   = var.use_tls ? "HTTPS" : "HTTP"
  ssl_policy = var.use_tls ? "ELBSecurityPolicy-TLS-1-1-2017-01" : null
}

resource "aws_lb" "lb" {
  name               = var.name
  internal           = var.internal
  load_balancer_type = "application"
  security_groups    = [aws_security_group.allow_http.id]
  subnets            = var.subnets
}

resource "aws_lb_target_group" "lb" {
  name        = var.name
  port        = local.port
  protocol    = local.protocol
  target_type = "ip"
  vpc_id      = var.vpc_id
}

resource "aws_lb_listener" "lb" {
  depends_on = [aws_lb_target_group.lb]

  load_balancer_arn = aws_lb.lb.arn
  port              = local.port
  protocol          = local.protocol
  ssl_policy        = local.ssl_policy
  certificate_arn   = local.cert_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lb.arn
  }
}

#############################################
## SecurityGroup Resources
#############################################
resource "aws_security_group" "allow_http" {
  name        = "${var.name}-allow-http"
  description = "Allow HTTP inbound traffic"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = local.port
    protocol    = "tcp"
    to_port     = local.port
    cidr_blocks = [local.lb_sg_cidr]
  }

  egress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name}-allow-http"
  }
}

resource "aws_security_group" "task" {
  name        = var.name
  description = "Allow traffic from the load balancer into the task"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = local.port
    protocol        = "tcp"
    to_port         = local.port
    security_groups = [aws_security_group.allow_http.id]
  }

  tags = {
    Name = var.name
  }
}