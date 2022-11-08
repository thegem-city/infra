provider "aws" {
  region              = "us-east-2"
  allowed_account_ids = [123456]
}

terraform {
  backend "s3" {
    bucket  = "the-infra-bucket-we-use"
    key     = "app/terraform.tfstate"
    region  = "us-east-2"
    encrypt = true
  }
}

data "aws_caller_identity" "current" {}
