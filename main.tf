terraform {
  required_version = ">= 1.3"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.65"
    }
  }
}

resource "random_id" "id" {
  byte_length = 14
}
