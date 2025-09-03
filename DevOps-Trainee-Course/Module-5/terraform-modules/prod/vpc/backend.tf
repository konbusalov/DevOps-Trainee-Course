terraform {
  backend "s3" {
    bucket = "terraform-trainee-state-bucket"
    key = "prod/vpc.tfstate"
    region = "eu-north-1"
    profile = "trainee"
    dynamodb_table = "terraform-trainee-state-lock"
    encrypt = true
  }
}