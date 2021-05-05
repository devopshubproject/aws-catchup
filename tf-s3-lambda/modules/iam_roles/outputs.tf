output "iam_rolename" {
  value = aws_iam_role.aws_role[0].name
}

output "role_arn" {
  value = aws_iam_role.aws_role[0].arn
}

output "role_id" {
  value = aws_iam_role.aws_role[0].id
}