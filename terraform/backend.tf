terraform {
  backend "s3" {
    bucket       = "meridian-app-tfstate-munirih-020926"
    key          = "meridian-app-infrastructure/terraform.tfstate"
    region       = "us-east-1"
    use_lockfile = true
    encrypt      = true
  }
}
