locals {
  container_definition = <<DEFINITION
[
  {
    "image": "${aws_ecr_repository.repo.repository_url}:${var.container_image_tag}",
    "name": "${var.container_name}",
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
        "awslogs-group":          "${var.name}",
        "awslogs-region":         "${var.region}",
        "awslogs-stream-prefix":  "back"
      }
    }
  }
]
DEFINITION
}