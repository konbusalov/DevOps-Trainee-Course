terraform {
  backend "s3" {
    bucket = "trainee-project-busalov-konstantin-tfstate"
    key = "terraform/terraform.tfstate"
    region = "eu-north-1"
    profile = "trainee"
    dynamodb_table = "trainee-project-busalov-konstantin-tfstate-lock"
    encrypt = true
  }
}