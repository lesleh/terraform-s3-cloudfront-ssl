output "bucket_arn" {
  description = "ARN of the bucket"
  value       = aws_s3_bucket.s3_bucket.arn
}

output "bucket_id" {
  description = "ID of the bucket"
  value       = aws_s3_bucket.s3_bucket.id
}

output "cloudfront_arn" {
  description = "ARN of the cloudfront distribution"
  value       = aws_cloudfront_distribution.cf_distribution.arn
}

output "domain" {
  description = "Domain name of the cloudfront distribution"
  value       = var.domain_name
}
