terraform {
  backend "local" {}

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      #version = "6.27.0" # got error "An argument named "bucket_namespace" is not expected here."
      version = "6.53.0"
    }
  }
}
#############################################
# Configuration from ~/.aws are used 
# to provide creds to AWS.
# AWS Account are provided with the following 
# Managed Polycies:
# - AmazonEC2FullAccess
# - IAMFullAccess
#############################################
#provider "aws" {
#  region = 
#  access_key = 
#  secret_key = 
#}

#  block that lets to name and compute values to reuse them repeatedly across the codebase
locals{} 
  
resource "aws_s3_bucket" "devops-experts-class10-maria-sokolova" {
  bucket = "devops-experts-class10-maria-sokolova" 
  bucket_namespace = "global"
}

resource "aws_s3_object" "example_file" {
  bucket = aws_s3_bucket.devops-experts-class10-maria-sokolova.id
  key    = "1.txt"   # path/name inside S3
  source = "./1.txt"  # local file path
}

output "bucket_domain_name" {
  value = aws_s3_bucket.devops-experts-class10-maria-sokolova.bucket_domain_name
}
output "etag" { # MD5 digest of the object(file) data
  value = aws_s3_object.example_file.etag
}



