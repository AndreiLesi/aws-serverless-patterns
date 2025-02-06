provider "aws" {
  region = "eu-central-1"
  default_tags {
    tags = local.default_tags.tags
  }
}

terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}