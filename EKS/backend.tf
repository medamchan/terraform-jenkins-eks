terraform {
  backend "s3" {
    bucket = "tform-jenkins-eks"
    key    = "eks/terraform.tfstate"
    region = "us-east-1"

  }
}