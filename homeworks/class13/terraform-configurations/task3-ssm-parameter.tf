resource "aws_ssm_parameter" "some-string-value" {
  name  = "some-string-value"
  type  = "String"
  value = "StringValue"
}