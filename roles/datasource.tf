# --- roles/datasource.tf ---
data "aws_iam_policy_document" "assume_role_ec2" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "allow_s3" {
  statement {
    actions   = ["s3:*"]
    resources = ["${var.history_archive_arn}/*"]
  }
}


# --- AWS managed policies ---
data "aws_iam_policy" "AmazonSSMManagedInstanceCore" {
  arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}
data "aws_iam_policy" "AmazonSSMPatchAssociation" {
  arn = "arn:aws:iam::aws:policy/AmazonSSMPatchAssociation"
}