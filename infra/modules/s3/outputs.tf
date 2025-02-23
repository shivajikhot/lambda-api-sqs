output "src_bucket_arn" {
  value = aws_s3_bucket.buckets[var.bucket_names[0]].arn
}

output "src_bucket_id" {
  value = aws_s3_bucket.buckets[var.bucket_names[0]].id
}

output "dst_bucket_arn" {
  value = aws_s3_bucket.buckets[var.bucket_names[1]].arn
}

output "dst_bucket_id" {
  value = aws_s3_bucket.buckets[var.bucket_names[1]].id
}
