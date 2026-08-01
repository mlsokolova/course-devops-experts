resource "aws_cloudwatch_metric_alarm" "lambda-duration-threshold-exceed" {
  alarm_name                = "LambdaDurationThresholdExceed"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  metric_name               = "Duration"
  namespace                 = "AWS/Lambda"
  period                    = 60
  statistic                 = "Average"
  threshold                 = 30000
  alarm_description         = "This metric monitors lambda duration"
}

resource "aws_cloudwatch_metric_alarm" "lambda-error-threshold-exceed" {
  alarm_name                = "LambdaErrorThresholdExceed"
  comparison_operator       = "GreaterThanThreshold"
  evaluation_periods        = 1
  metric_name               = "Errors"
  namespace                 = "AWS/Lambda"
  period                    = 60
  statistic                 = "Sum"
  threshold                 = 0
  alarm_description         = "This metric monitors lambda errors"
}

resource "aws_cloudwatch_metric_alarm" "lambda-invocations-threshold-exceed" {
  alarm_name                = "LambdaInvocationsThresholdExceed"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  metric_name               = "Invocations"
  namespace                 = "AWS/Lambda"
  period                    = 60
  statistic                 = "Sum"
  threshold                 = 5
  alarm_description         = "This metric monitors lambda invocations"
}