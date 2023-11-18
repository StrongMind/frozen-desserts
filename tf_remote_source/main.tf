provider "aws" {
  region = "us-west-1"
}

resource "aws_s3_bucket" "fd_tfstate" {
  bucket = "fd-tfstate"
}