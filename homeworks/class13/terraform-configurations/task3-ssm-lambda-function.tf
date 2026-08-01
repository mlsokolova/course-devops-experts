locals {
  ssm_lambda_function_name = "class13-read-ssm-parameter"
}

module "ssm_lambda_function" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "~> 8.0"

  function_name = local.ssm_lambda_function_name
  description   = "Read a value from SSM Parameter Store"

  runtime = "python3.11"
  handler = "ssm_lambda_function.lambda_handler"

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
    PARAMETER_NAME = aws_ssm_parameter.some-string-value.name
    S3_BUCKET = aws_s3_bucket.class13-home-assignment.bucket
  }

  attach_policy_statements = true
  policy_statements = {
    ssm_read = {
      effect    = "Allow"
      actions   = ["ssm:GetParameter"]
      resources = [aws_ssm_parameter.some-string-value.arn]
    }
    s3_put = {
      effect    = "Allow"
      actions   = ["s3:PutObject"]
      resources = ["${aws_s3_bucket.class13-home-assignment.arn}/*"]
    }
  }

  cloudwatch_logs_retention_in_days = 7

  tags = {
    Name = local.ssm_lambda_function_name
  }
}
