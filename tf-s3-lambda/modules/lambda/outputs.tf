
output "lambda_arn" {
  value = aws_lambda_function.aws_lambda[0].arn
}