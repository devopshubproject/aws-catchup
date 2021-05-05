output "s3_bucket_name" {
  value = module.s3.bucket_name
}

output "s3_bucket_arn" {
  value = module.s3.bucket_arn
}

output "lambda_role_arn" {
  value = module.lambda_role.role_arn
}

output "lambda_role_id" {
  value = module.lambda_role.role_id
}

output "lambda_role_policy" {
  value = module.iam_policy_for_lambda_logging.policy_arn
}