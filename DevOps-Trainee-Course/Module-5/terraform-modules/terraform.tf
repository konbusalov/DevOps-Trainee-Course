provider "aws" {
  region = var.region
  shared_config_files = ["/home/kon/.aws/config"]
  shared_credentials_files = [ "/home/kon/.aws/credentials" ]
  profile = "trainee"
  default_tags {
    tags = {
        Owner = "Konstantin Busalov"
    }
  }
}