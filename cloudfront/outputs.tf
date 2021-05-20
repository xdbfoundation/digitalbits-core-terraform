# --- cloudfront/outputs.tf ---
output "history_archive_arn" {
  value = aws_s3_bucket.history_archive.arn
}
output "cloudfront_domain_name" {
  value = aws_cloudfront_distribution.history_distribution.domain_name
}