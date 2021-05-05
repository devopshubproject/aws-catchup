
output "bucket_name" {
  value = aws_s3_bucket.aws_s3_bucket[0].bucket
}

output "bucket_arn" {
  value = aws_s3_bucket.aws_s3_bucket[0].arn
}