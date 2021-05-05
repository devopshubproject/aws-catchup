variable "bucket_name" {
  description = "Name of the bucket"
}

variable "bucket_tag" {
  default = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}

variable "create_bucket" {
  description = "Whether to create bucket or not"
}

variable "lambda_arn" {
}

variable "enable_bucket_notification" {
}

variable "s3_trigger_lambda" {
}