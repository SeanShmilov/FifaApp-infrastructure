resource "aws_ecr_repository" "frontend" {
  name                 = "fraudsterslist-frontend"
  image_tag_mutability = "MUTABLE"
  force_delete         = true

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = { Project = "FraudstersList" }
}

resource "aws_ecr_repository" "backend" {
  name                 = "fraudsterslist-backend"
  image_tag_mutability = "MUTABLE"
  force_delete         = true

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = { Project = "FraudstersList" }
}
