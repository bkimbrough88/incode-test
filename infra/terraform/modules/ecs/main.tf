#############################################
## CloudWatch Resources
#############################################
#resource "aws_cloudwatch_metric_alarm" "tbd" {
#  alarm_name          = ""
#  comparison_operator = ""
#  evaluation_periods  = 0
#}

#############################################
## CertManager Resources
#############################################
resource "aws_acm_certificate" "back" {
  count = var.use_tls ? 1 : 0

  domain_name       = "api.incode-test.com"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}
resource "aws_acm_certificate" "front" {
  count = var.use_tls ? 1 : 0

  domain_name       = "incode-test.com"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

#############################################
## ECR Resources
#############################################
resource "aws_ecr_repository" "repo" {
  name         = "incode-test"
  force_delete = true   # just for easy cleanup of environment

  image_scanning_configuration {
    scan_on_push = true
  }
}

#############################################
## ECS Resources
#############################################
resource "aws_ecs_cluster" "cluster" {
  name = "incode-test"
}

locals {
  back_container_definition = <<DEFINITION
[
  {
    "image": "${aws_ecr_repository.repo.repository_url}/${var.back_image_name}:${var.back_image_tag}",
    "name": "incode-test-back",
    "portMappings":  [
      {
        "appProtocol": "http",
        "containerPort": ${local.port},
        "name": "http"
      }
    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-create-group":   "true",
        "awslogs-group":          "incode-test-back",
        "awslogs-region":         "${data.aws_region.current.name}",
        "awslogs-stream-prefix":  "back"
      }
    }
  }
]
DEFINITION
}

resource "aws_ecs_task_definition" "back" {
  container_definitions    = local.back_container_definition
  cpu                      = "128"
  family                   = "incode-test-back"
  execution_role_arn       = aws_iam_role.task_execution_role.arn
  memory                   = "256"
  network_mode             = "awsvpc"
  requires_compatibilities = ["EC2"]
  task_role_arn            = aws_iam_role.back_task_role.arn
}

resource "aws_ecs_service" "back" {
  name                       = "incode-test-back"
  cluster                    = aws_ecs_cluster.cluster.id
  desired_count              = 2
  deployment_maximum_percent = 200
  launch_type                = "EC2"
  task_definition            = aws_ecs_task_definition.back.arn

  load_balancer {
    container_name   = "incode-test-back"
    container_port   = local.port
    target_group_arn = aws_lb_target_group.back.arn
  }

  network_configuration {
    subnets         = var.private_subnets
    security_groups = [aws_security_group.back_task.id]
  }

  ordered_placement_strategy {
    type  = "binpack"
    field = "cpu"
  }
}

locals {
  front_container_definition = <<DEFINITION
[
  {
    "image": "${aws_ecr_repository.repo.repository_url}/${var.front_image_name}:${var.front_image_tag}",
    "name": "incode-test-front",
    "portMappings": [
      {
        "appProtocol": "http",
        "containerPort": ${local.port},
        "name": "http"
      }
    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-create-group":   "true",
        "awslogs-group":          "incode-test-front",
        "awslogs-region":         "${data.aws_region.current.name}",
        "awslogs-stream-prefix":  "front"
      }
    }
  }
]
DEFINITION
}

resource "aws_ecs_task_definition" "front" {
  container_definitions    = local.front_container_definition
  cpu                      = "128"
  family                   = "incode-test-front"
  execution_role_arn       = aws_iam_role.task_execution_role.arn
  memory                   = "256"
  network_mode             = "awsvpc"
  requires_compatibilities = ["EC2"]
  task_role_arn            = aws_iam_role.front_task_role.arn
}

resource "aws_ecs_service" "front" {
  name                       = "incode-test-front"
  cluster                    = aws_ecs_cluster.cluster.id
  desired_count              = 2
  deployment_maximum_percent = 200
  launch_type                = "EC2"
  task_definition            = aws_ecs_task_definition.front.arn

  load_balancer {
    container_name   = "incode-test-front"
    container_port   = local.port
    target_group_arn = aws_lb_target_group.front.arn
  }

  network_configuration {
    subnets         = var.private_subnets
    security_groups = [aws_security_group.front_task.id]
  }

  ordered_placement_strategy {
    type  = "binpack"
    field = "cpu"
  }
}

#############################################
## IAM Resources
#############################################
resource "aws_iam_role" "task_execution_role" {
  name               = "incode-test-execution"
  assume_role_policy = data.aws_iam_policy_document.task_execution_assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "task_execution_role" {
  policy_arn = data.aws_iam_policy.task_execution.arn
  role       = aws_iam_role.task_execution_role.name
}

# Backend Roles
resource "aws_iam_role" "back_task_role" {
  name               = "incode-test-back-task"
  assume_role_policy = data.aws_iam_policy_document.task_execution_assume_role_policy.json
}

resource "aws_iam_policy" "back_task_role" {
  name   = "incode-test-back-task"
  policy = data.aws_iam_policy_document.back_task_policy.json
}

resource "aws_iam_role_policy_attachment" "back_task_role" {
  policy_arn = aws_iam_policy.back_task_role.arn
  role       = aws_iam_role.back_task_role.name
}

# Frontend Roles
resource "aws_iam_role" "front_task_role" {
  name               = "incode-test-front-task"
  assume_role_policy = data.aws_iam_policy_document.task_execution_assume_role_policy.json
}

resource "aws_iam_policy" "front_task_role" {
  name   = "incode-test-front-task"
  policy = data.aws_iam_policy_document.front_task_policy.json
}

resource "aws_iam_role_policy_attachment" "front_task_role" {
  policy_arn = aws_iam_policy.front_task_role.arn
  role       = aws_iam_role.front_task_role.name
}

#############################################
## LoadBalancer Resources
#############################################
locals {
  back_cert_arn  = var.use_tls ? aws_acm_certificate.back[0].arn : null
  front_cert_arn = var.use_tls ? aws_acm_certificate.front[0].arn : null
  port           = var.use_tls ? 443 : 80
  protocol       = var.use_tls ? "HTTPS" : "HTTP"
  ssl_policy     = var.use_tls ? "ELBSecurityPolicy-TLS-1-1-2017-01" : null
}

resource "aws_lb" "back" {
  name               = "incode-test-back"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [aws_security_group.allow_internal_http.id]
  subnets            = var.private_subnets
}

resource "aws_lb_target_group" "back" {
  name        = "incode-test-back"
  port        = local.port
  protocol    = local.protocol
  target_type = "ip"
  vpc_id      = var.vpc_id
}

resource "aws_lb_listener" "back" {
  load_balancer_arn = aws_lb.back.arn
  port              = local.port
  protocol          = local.protocol
  ssl_policy        = local.ssl_policy
  certificate_arn   = local.back_cert_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.back.arn
  }
}

resource "aws_lb" "front" {
  name               = "incode-test-front"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.allow_public_http.id]
  subnets            = var.public_subnets
}

resource "aws_lb_target_group" "front" {
  name        = "incode-test-front"
  port        = local.port
  protocol    = local.protocol
  target_type = "ip"
  vpc_id      = var.vpc_id
}

resource "aws_lb_listener" "front" {
  load_balancer_arn = aws_lb.front.arn
  port              = local.port
  protocol          = local.protocol
  ssl_policy        = local.ssl_policy
  certificate_arn   = local.front_cert_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.front.arn
  }
}

#############################################
## SecurityGroup Resources
#############################################
resource "aws_security_group" "allow_public_http" {
  name        = "allow-public-http"
  description = "Allow public HTTP inbound traffic"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = local.port
    protocol    = "tcp"
    to_port     = local.port
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow-public-http"
  }
}

resource "aws_security_group" "allow_internal_http" {
  name        = "allow-internal-http"
  description = "Allow internal HTTP inbound traffic"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = local.port
    protocol    = "tcp"
    to_port     = local.port
    cidr_blocks = [var.vpc_cidr]
  }

  tags = {
    Name = "allow-internal-http"
  }
}

resource "aws_security_group" "back_task" {
  name        = "back-task"
  description = "Allow traffic from the load balancer into the back tasks"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = local.port
    protocol        = "tcp"
    to_port         = local.port
    security_groups = [aws_security_group.allow_internal_http.id]
  }
}

resource "aws_security_group" "front_task" {
  name        = "front-task"
  description = "Allow traffic from the load balancer into the front tasks"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = local.port
    protocol        = "tcp"
    to_port         = local.port
    security_groups = [aws_security_group.allow_public_http.id]
  }
}