data "tls_certificate" "tfc" {
  url = "https://app.terraform.io"
}

resource "aws_iam_openid_connect_provider" "tfc" {
  url             = "https://app.terraform.io"
  client_id_list  = ["aws.workload.identity"]
  thumbprint_list = [data.tls_certificate.tfc.certificates[0].sha1_fingerprint]
}

data "aws_iam_policy_document" "tfc_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.tfc.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "app.terraform.io:aud"
      values   = ["aws.workload.identity"]
    }

    condition {
      test     = "StringLike"
      variable = "app.terraform.io:sub"
      values   = ["organization:${var.tfc_organization}:project:*:workspace:${var.tfc_workspace}:run_phase:*"]
    }
  }
}

resource "aws_iam_role" "tfc" {
  name               = "tfc-${var.tfc_workspace}-role"
  assume_role_policy = data.aws_iam_policy_document.tfc_assume_role.json
  tags               = { Project = "FifaApp" }
}

resource "aws_iam_role_policy_attachment" "tfc_admin" {
  role       = aws_iam_role.tfc.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

output "tfc_role_arn" {
  description = "Set this as TFC_AWS_RUN_ROLE_ARN in the TFC workspace env vars"
  value       = aws_iam_role.tfc.arn
}
