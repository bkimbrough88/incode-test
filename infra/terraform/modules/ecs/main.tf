resource "aws_cloudwatch_log_group" "front" {
  name = "incode-test-front"
}

resource "aws_cloudwatch_log_stream" "front" {
  log_group_name = aws_cloudwatch_log_group.front.name
  name           = "incode-test-front"
}

resource "aws_cloudwatch_log_group" "back" {
  name = "incode-test-back"
}

resource "aws_cloudwatch_log_stream" "back" {
  log_group_name = aws_cloudwatch_log_group.back.name
  name           = "incode-test-back"
}

resource "aws_ecr_repository" "repo" {
  name         = "incode-test"
  force_delete = true   # just for easy cleanup of environment

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecs_cluster" "cluster" {
  name = "incode-test"
}

resource "aws_iam_role" "task_execution_role" {
  name               = "incode-test-execution"
  assume_role_policy = data.aws_iam_policy_document.task_execution_assume_role_policy.json
}

resource "aws_iam_role" "front_task_role" {
  name               = "incode-test-front-task"
  assume_role_policy = data.aws_iam_policy_document.task_execution_assume_role_policy.json
}

resource "aws_iam_role" "back_task_role" {
  name               = "incode-test-back-task"
  assume_role_policy = data.aws_iam_policy_document.task_execution_assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "task_execution_role" {
  policy_arn = data.aws_iam_policy.task_execution.arn
  role       = aws_iam_role.task_execution_role.name
}

resource "aws_iam_policy" "front_task_policy" {
  name   = "incode-test-front-task"
  policy = data.aws_iam_policy_document.front_task_policy.json
}

resource "aws_iam_role_policy_attachment" "front_task_role" {
  policy_arn = aws_iam_policy.front_task_policy.arn
  role       = aws_iam_role.front_task_role.name
}

resource "aws_iam_policy" "back_task_policy" {
  name   = "incode-test-back-task"
  policy = data.aws_iam_policy_document.back_task_policy.json
}

resource "aws_iam_role_policy_attachment" "back_task_role" {
  policy_arn = aws_iam_policy.back_task_policy.arn
  role       = aws_iam_role.back_task_role.name
}

locals {
  front_container_definition = <<DEFINITION
[
  {
    "image": "${aws_ecr_repository.repo.repository_url}/incode-test-front:latest",
    "name": "incode-test-front",
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-region": "${data.aws_region.current.name}",
        "awslogs-group": "${aws_cloudwatch_log_group.front.name}",
        "awslogs-stream": "${aws_cloudwatch_log_stream.front.name}"
      }
    }
  }
]
DEFINITION
}

resource "aws_ecs_task_definition" "front" {
  container_definitions    = local.front_container_definition
  cpu                      = "100"
  family                   = "incode-test-front"
  execution_role_arn       = aws_iam_role.task_execution_role.arn
  memory                   = "512"
  network_mode             = "awsvpc"
  requires_compatibilities = ["EC2", "FARGATE"]
  task_role_arn            = aws_iam_role.front_task_role.arn
}

locals {
  back_container_definition = <<DEFINITION
[
  {
    "image": "${aws_ecr_repository.repo.repository_url}/incode-test-back:latest",
    "name": "incode-test-front",
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-region": "${data.aws_region.current.name}",
        "awslogs-group": "${aws_cloudwatch_log_group.back.name}",
        "awslogs-stream": "${aws_cloudwatch_log_stream.back.name}"
      }
    }
  }
]
DEFINITION
}

resource "aws_ecs_task_definition" "back" {
  container_definitions    = local.back_container_definition
  cpu                      = "100"
  family                   = "incode-test-back"
  execution_role_arn       = aws_iam_role.task_execution_role.arn
  memory                   = "512"
  network_mode             = "awsvpc"
  requires_compatibilities = ["EC2", "FARGATE"]
  task_role_arn            = aws_iam_role.back_task_role.arn
}