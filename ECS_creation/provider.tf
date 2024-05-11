terraform {
  required_version = ">= 0.13"  // Ensure your Terraform version is at least 0.13

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.0"  // Specify the minimum version of the AWS provider
    }
  }
}

provider "aws" {
  region = "us-east-1"  // Specify the region, other configurations as needed
}
