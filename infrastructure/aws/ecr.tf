locals {
  repos = ["frontend", "backend"]
}

resource "aws_ecr_repository" "this" {
  for_each             = toset(local.repos)
  name                 = "lightfeather-devops-code-challenge-${each.value}"
  image_tag_mutability = "MUTABLE"
  encryption_configuration {
    encryption_type = "KMS"
  }
  image_scanning_configuration {
    scan_on_push = true
  }
}
