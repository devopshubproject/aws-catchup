
provider "aws" {
  region = "us-east-1"
  version = ">= 2.38.0"
}

module "s3" {
  source        = "./modules/s3"
  bucket_name   = "s3lambda-integration-bucket"
  create_bucket = "true"
  enable_bucket_notification = "true"
  s3_trigger_lambda = "true"
  lambda_arn = module.aws_lambda.lambda_arn
}

module "lambda_role" {
  source             = "./modules/iam_role"
  create_lambda_role = "true"
  role_name          = "lambda_basic_execution_role_maity"
  role_policy_json   = <<EOT
{
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : "sts:AssumeRole",
        "Principal" : {
          "Service" : "lambda.amazonaws.com"
        },
        "Effect" : "Allow",
        "Sid" : ""
      }
    ]
}
EOT
}

module "aws_lambda" {
  source = "./modules/lambda"
  create_lambda = "true"
  lambda_role_arn = module.lambda_role.role_arn
  lambda_function_name = "execute_lambda_on_object_upload_smaity"
  lambda_zip_file = "lambda_function.zip"
  add_lambda_trigger = "true"
  trigger_type = "s3"
  bucket_arn = module.s3.bucket_arn
}

module "iam_policy_for_lambda_logging" {
  source = "./modules/iam_policy"
  create_iam_policy = "true"
  attach_policy = "true"
  iam_role_name = module.lambda_role.iam_rolename
  policy_name = "iam_policy_for_lambda_logging"
  policy_json = var.lambda_logging_policy_json
}

