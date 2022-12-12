locals {
  container_definition = <<DEFINITION
[
  {
    "image": "${var.image_repo}/${var.container_image}:${var.container_image_tag}",
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