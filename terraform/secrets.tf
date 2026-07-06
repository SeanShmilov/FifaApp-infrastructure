# AWS Secrets Manager Secret
resource "aws_secretsmanager_secret" "mongodb_uri" {
  name                    = "fraudsterslist/mongo_uri"
  recovery_window_in_days = 0 # Force immediate deletion for testing
  tags                    = { Project = "FraudstersList" }
}

resource "aws_secretsmanager_secret_version" "mongodb_uri_initial" {
  secret_id     = aws_secretsmanager_secret.mongodb_uri.id
  secret_string = "mongodb+srv://REPLACE_ME:REPLACE_ME@cluster0.mongodb.net/fraudsterslist?retryWrites=true&w=majority"
  
  # Ignore changes so if the user updates it manually in AWS, Terraform doesn't revert it
  lifecycle {
    ignore_changes = [secret_string]
  }
}

# IAM Policy to read the secret
resource "aws_iam_policy" "external_secrets" {
  name        = "FraudstersListExternalSecretsPolicy"
  description = "Allow External Secrets Operator to read from Secrets Manager"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "secretsmanager:GetResourcePolicy",
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret",
          "secretsmanager:ListSecretVersionIds"
        ]
        Effect   = "Allow"
        Resource = [aws_secretsmanager_secret.mongodb_uri.arn]
      }
    ]
  })
}

# IRSA Role for the External Secrets Operator
module "external_secrets_irsa_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.30"

  role_name = "fraudsterslist-external-secrets-role"

  attach_external_secrets_policy = false
  role_policy_arns = {
    secrets = aws_iam_policy.external_secrets.arn
  }

  oidc_providers = {
    ex = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["external-secrets:external-secrets"]
    }
  }

  tags = { Project = "FraudstersList" }
}

# Helm Release for External Secrets Operator
resource "helm_release" "external_secrets" {
  name             = "external-secrets"
  repository       = "https://charts.external-secrets.io"
  chart            = "external-secrets"
  namespace        = "external-secrets"
  create_namespace = true
  version          = "0.9.13"

  set {
    name  = "installCRDs"
    value = "true"
  }

  set {
    name  = "serviceAccount.name"
    value = "external-secrets"
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = module.external_secrets_irsa_role.iam_role_arn
  }
}
