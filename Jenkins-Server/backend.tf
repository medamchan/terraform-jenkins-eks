terraform {
  backend "s3" {
    bucket = "tform-jenkins-eks"
    key    = "jenkins/terraform.tfstate"
    region = "us-east-1"
  }
}