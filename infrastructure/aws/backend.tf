# This file defines the Terraform backend (not the application backend).

module "backend_s3_bucket" {
  source             = "github.com/bananalab/terraform-modules//modules/aws-s3-bucket?ref=v0.3.1"
  bucket             = "lightfeather-devops-code-challenge-${data.aws_caller_identity.current.account_id}"
  enable_replication = false
  logging_enabled    = false
}

resource "aws_dynamodb_table" "this" {
  name           = "lightfeather-devops-code-challenge-terraform-lock"
  billing_mode   = "PROVISIONED"
  hash_key       = "LockID"
  read_capacity  = 20
  write_capacity = 20
  attribute {
    name = "LockID"
    type = "S"
  }
}
