terraform {
  backend "s3" {
    bucket         = "lightfeather-devops-code-challenge-202151242785"
    dynamodb_table = "lightfeather-devops-code-challenge-terraform-lock"
    key            = "terraform.tfstate"
    region         = "us-west-1"
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
    github = {
      source  = "integrations/github"
      version = "~> 5.0"
    }
  }
}
