resource "aws_ecr_repository" "frontend" {
  name                 = "fifaapp-frontend"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Environment = "production"
    Project     = "FifaApp"
  }
}

resource "aws_ecr_repository" "backend" {
  name                 = "fifaapp-backend"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Environment = "production"
    Project     = "FifaApp"
  }
}
