locals {
  lambda_function_name = "class13-read-secret-password"
}

module "lambda_function" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "~> 8.0"

  function_name = local.lambda_function_name
  description   = "Read the secret, print its length"

  runtime = "python3.11"
  handler = "lambda_function.lambda_handler"

  # The module packages the files from this directory into a ZIP archive.
  source_path = "${path.module}/src"

  memory_size = 128
  timeout     = 30

  # Publish a numbered Lambda version.
  #
  # This avoids an allowed-trigger issue where Lambda permissions cannot
  # be attached to a qualified $LATEST version in some module configurations.
  publish = true

  environment_variables = {
    SECRET_NAME = aws_secretsmanager_secret.random-passwd.name
  }

  attach_policy_statements = true
  policy_statements = {
    secretsmanager_read = {
      effect    = "Allow"
      actions   = ["secretsmanager:GetSecretValue"]
      resources = [aws_secretsmanager_secret.random-passwd.arn]
    }
  }

  cloudwatch_logs_retention_in_days = 7

  tags = {
    Name = local.lambda_function_name
  }
}
