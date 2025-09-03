data "terraform_remote_state" "vpc" {
    backend = "s3"
    config = {
        bucket = "terraform-trainee-state-bucket"
        key = "dev/vpc.tfstate"
        region = "eu-north-1"
        use_lockfile = true
    }
}