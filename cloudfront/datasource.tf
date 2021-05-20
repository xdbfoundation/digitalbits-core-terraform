# --- cloudfront/datasource.tf ---
data "aws_iam_policy_document" "read_s3" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.history_archive.arn}/*"]
    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.origin_access_identity.iam_arn]
    }
  }
}

