variable "lambda_zip_file" {
  description = "Path of the zip file"
}

variable "lambda_function_name" {
  description = "Name of the lambda function"
}

variable "lambda_runtime_engine" {
  default = "python3.8"
  description = "Name of the lambda runtime engine name"
}

variable "create_lambda" {
  description = "Whether to create lambda or not"
}

variable "lambda_role_arn" {
  description = "Role ARN for Lambda"
}

variable "add_lambda_trigger" {
  default = "false"
}


variable "trigger_type" {
  default = "none"
}

variable "bucket_arn" {
  default = "none"
}