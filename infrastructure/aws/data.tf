# Place common data sources in this file.

data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_caller_identity" "current" {}
