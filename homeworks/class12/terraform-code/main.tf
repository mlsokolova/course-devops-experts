terraform {
  backend "local" {}

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.53.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = {
      Project   = "class12"
      ManagedBy = "Terraform"
    }
  }
}

###############################################################################
# Local values
###############################################################################

locals {
  project_name = "class12"

  lambda_function_name = "${local.project_name}-processor"
  dynamodb_table_name  = "${local.project_name}-messages"
  sns_topic_name       = "${local.project_name}-topic"
}

###############################################################################
# DynamoDB table
###############################################################################

resource "aws_dynamodb_table" "messages" {
  name         = local.dynamodb_table_name
  billing_mode = "PAY_PER_REQUEST"

  # The partition key must be included in every PutItem request.
  hash_key = "message_id"

  attribute {
    name = "message_id"
    type = "S"
  }

#  point_in_time_recovery {
#    enabled = true
#  }

#  server_side_encryption {
#    enabled = true
#  }

  tags = {
    Name = local.dynamodb_table_name
  }
}

###############################################################################
# SNS topic
###############################################################################

resource "aws_sns_topic" "messages" {
  name = local.sns_topic_name

  tags = {
    Name = local.sns_topic_name
  }
}

###############################################################################
# Lambda function
###############################################################################

module "lambda_function" {
  source  = "terraform-aws-modules/lambda/aws"
  # version = "8.8.1"

  function_name = local.lambda_function_name
  description   = "Processes SNS messages and writes them to DynamoDB"

  runtime = "python3.12"
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
    DYNAMODB_TABLE_NAME = aws_dynamodb_table.messages.name
  }

  cloudwatch_logs_retention_in_days = 14

  # Create policy statements and attach them to the Lambda execution role.
  attach_policy_statements = true

  policy_statements = {
    dynamodb_write = {
      effect = "Allow"

      actions = [
        "dynamodb:PutItem",
        "dynamodb:UpdateItem",
        "dynamodb:GetItem"
      ]

      resources = [
        aws_dynamodb_table.messages.arn
      ]
    }
  }

  # This creates aws_lambda_permission so that SNS may invoke Lambda.
  allowed_triggers = {
    sns = {
      principal  = "sns.amazonaws.com"
      source_arn = aws_sns_topic.messages.arn
    }
  }

  tags = {
    Name = local.lambda_function_name
  }
}

###############################################################################
# SNS subscription
###############################################################################

# allowed_triggers grants permission to SNS.
# This resource creates the actual SNS-to-Lambda subscription.
resource "aws_sns_topic_subscription" "lambda" {
  topic_arn = aws_sns_topic.messages.arn
  protocol  = "lambda"
  endpoint  = module.lambda_function.lambda_function_arn

  depends_on = [
    module.lambda_function
  ]
}

###############################################################################
# Outputs
###############################################################################

output "aws_region" {
  description = "AWS region containing the resources"
  value       = data.aws_region.current.region
}

output "dynamodb_table_name" {
  description = "DynamoDB table name"
  value       = aws_dynamodb_table.messages.name
}

output "dynamodb_table_arn" {
  description = "DynamoDB table ARN"
  value       = aws_dynamodb_table.messages.arn
}

output "sns_topic_arn" {
  description = "SNS topic ARN"
  value       = aws_sns_topic.messages.arn
}

output "lambda_function_name" {
  description = "Lambda function name"
  value       = module.lambda_function.lambda_function_name
}

output "lambda_function_arn" {
  description = "Lambda function ARN"
  value       = module.lambda_function.lambda_function_arn
}

###############################################################################
# Data sources
###############################################################################

data "aws_region" "current" {}