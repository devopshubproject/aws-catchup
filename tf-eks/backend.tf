terraform {
  backend "s3" {
    bucket = "layabucket"
    key    = ""
    region = "us-east-1"
  }
}