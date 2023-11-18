terraform {
  backend "s3" {
    bucket = "fd-tfstate"
    key    = "fd_prod_terraform.tfstate"
    region = "us-west-1"
  }
}

provider "aws" {
  region = "us-west-1"
}

#
# Variables
#

variable "app_version" {
  type        = string
  description = "Application Version"
  default     = "1.0.0"
}

variable "secret_key_base" {
  type        = string
  description = "Rails secret_key_base"
  sensitive   = true
}

variable "db_password_prod" {
  type        = string
  description = "RDS Password"
  sensitive   = true
}

variable "db_user_prod" {
  type        = string
  description = "RDS User"
  sensitive   = true
}

#
# Define infra
#

resource "aws_s3_bucket" "fd_deploy_prod" {
  bucket = "fd-deploy-prod"
}

resource "aws_s3_object" "source_bundle" {
  bucket = aws_s3_bucket.fd_deploy_prod.id
  key    = "fd_prod_${var.app_version}.zip"
  source = "fd_prod.zip"
}

resource "aws_elastic_beanstalk_environment" "frozen_dessert_env_prod" {
  name                = "frozen-dessert-env-prod"
  application         = aws_elastic_beanstalk_application.frozen_dessert_prod.name
  solution_stack_name = "64bit Amazon Linux 2023 v4.0.0 running Ruby 3.2"
  version_label       = aws_elastic_beanstalk_application_version.frozen_dessert_prod.name

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "IamInstanceProfile"
    value     = aws_iam_instance_profile.fd_instance_profile.name
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "InstanceType"
    value     = "t3.medium"
  }

  setting {
    namespace = "aws:rds:dbinstance"
    name      = "DBAllocatedStorage"
    value     = "5"
  }

  setting {
    namespace = "aws:rds:dbinstance"
    name      = "DBDeletionPolicy"
    value     = "Snapshot"
  }

  setting {
    namespace = "aws:rds:dbinstance"
    name      = "HasCoupledDatabase"
    value     = "true"
  }

  setting {
    namespace = "aws:rds:dbinstance"
    name      = "DBEngine"
    value     = "postgres"
  }

  setting {
    namespace = "aws:rds:dbinstance"
    name      = "DBEngineVersion"
    value     = "16.1"
  }

  setting {
    namespace = "aws:rds:dbinstance"
    name      = "DBInstanceClass"
    value     = "db.t3.micro"
  }

  setting {
    namespace = "aws:rds:dbinstance"
    name      = "DBPassword"
    value     = var.db_password_prod
  }

  setting {
    namespace = "aws:rds:dbinstance"
    name      = "DBUser"
    value     = var.db_user_prod
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "SECRET_KEY_BASE"
    value     = var.secret_key_base
  }
}

resource "aws_elastic_beanstalk_application" "frozen_dessert_prod" {
  name        = "frozen_dessert"
  description = "Frozen Dessert demo application"
}

resource "aws_elastic_beanstalk_application_version" "frozen_dessert_prod" {
  name        = "frozen_dessert_${var.app_version}"
  application = "frozen_dessert"
  description = "Frozen Dessert demo application"
  bucket      = aws_s3_bucket.fd_deploy_prod.id
  key         = aws_s3_object.source_bundle.id
}

resource "aws_iam_instance_profile" "fd_instance_profile" {
  name  = "fd_instance_profile"
  role = aws_iam_role.fd_role.name
}

#
# Access policy
#

resource "aws_iam_role" "fd_role" {
  name = "fd_s3_access_role"
  description = "Frozen Dessert app IAM role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "fd_policy" {
  name        = "fd_policy"
  description = "S3 bucket access policy for Frozen Dessert EBS instance"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ],
        Effect = "Allow",
        Resource = [
          "${aws_s3_bucket.fd_deploy_prod.arn}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "fd_attach" {
  role       = aws_iam_role.fd_role.name
  policy_arn = aws_iam_policy.fd_policy.arn
}
