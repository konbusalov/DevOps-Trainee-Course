data "terraform_remote_state" "vpc" {
    backend = "s3"
    config = {
        bucket = "terraform-trainee-state-bucket"
        key = "prod/vpc.tfstate"
        region = "eu-north-1"
        use_lockfile = true
    }
}