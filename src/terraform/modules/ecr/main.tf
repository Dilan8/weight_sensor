resource "aws_ecr_repository" "weight_sensor_repo" {
  name                 = var.repository_name
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = var.repository_name
  }
}
