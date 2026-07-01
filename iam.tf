locals {
  students = yamldecode(file("${path.module}/students.yaml"))["students"]
}

resource "aws_iam_user" "students" {
  for_each = toset(local.students)
  name     = each.key
  tags = {
    Environment = "production"
    Project     = "FifaApp"
  }
}

# Attach an IAM policy (e.g., ReadOnlyAccess) to students for safety
resource "aws_iam_user_policy_attachment" "student_readonly" {
  for_each   = aws_iam_user.students
  user       = each.value.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}
