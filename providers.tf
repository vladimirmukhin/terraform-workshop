terraform {
  backend "s3" {
    bucket         = "terraform-remote-state-vladimir"
    key            = "main/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-lock-table"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = {
      Owner   = "Vladimir"
      Project = "Terraform-Workshop"
    }
  }
}
