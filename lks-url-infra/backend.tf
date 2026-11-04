terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket  = "lks-url-tfstate-Kediri-Budi" # GANTI sesuai nama bucket S3 kamu: lks-url-tfstate-<YourCity-YourName>
    key     = "lks-url/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "lks-url"
      Environment = "production"
      ManagedBy   = "terraform"
    }
  }
}
