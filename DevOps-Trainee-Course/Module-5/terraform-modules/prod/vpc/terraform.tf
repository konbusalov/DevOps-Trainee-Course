terraform {
  required_providers {
    aws = {
      version = "~> 6.10.0"
    }
  }

  required_version = "~> 1.13.0"
}

provider "aws" {
  region = "eu-north-1"
  shared_config_files = ["/home/kon/.aws/config"]
  shared_credentials_files = [ "/home/kon/.aws/credentials" ]
  profile = "trainee"
  default_tags {
    tags = {
        Owner = "Konstantin Busalov"
        Env = "prod"
    }
  }
}