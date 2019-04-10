provider "aws" {
  region = "eu-west-2"
  shared_credentials_file = "/c/Users/tapirs/.aws/credentials"
  profile                 = "terraform"
}

# terraform state file setup
# create an S3 bucket to store the state file in
resource "aws_s3_bucket" "terraform-state-storage-s3" {
    bucket = "cluster-terraform-state"

    versioning {
      enabled = true
    }

    lifecycle {
      prevent_destroy = true
    }

    server_side_encryption_configuration {
      rule {
        apply_server_side_encryption_by_default {
          sse_algorithm     = "AES256"
        }
      }
    }

    tags {
      Name = "S3 Remote Terraform State Store"
    }
}

# create a dynamodb table for locking the state file
resource "aws_dynamodb_table" "dynamodb-terraform-state-lock" {
  name = "terraform-state-lock-dynamo"
  hash_key = "LockID"
  read_capacity = 20
  write_capacity = 20

  attribute {
    name = "LockID"
    type = "S"
  }

  tags {
    Name = "DynamoDB Terraform State Lock Table"
  }
}
