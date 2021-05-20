# --- roles/main.tf ---
resource "aws_iam_role" "LivenetNodeRole" {
  name               = "LivenetNodeRole"
  assume_role_policy = data.aws_iam_policy_document.assume_role_ec2.json
  tags = {
    Name = "LivenetNodeRole"
  }
}

resource "aws_iam_policy" "HistoryArchiveFullAccess" {
  name        = "HistoryArchiveFullAccess"
  description = "Provides full access to history archive bucket"
  policy      = data.aws_iam_policy_document.allow_s3.json
}

resource "aws_iam_role_policy_attachment" "attach_HistoryArchiveFullAccess" {
  role       = aws_iam_role.LivenetNodeRole.name
  policy_arn = aws_iam_policy.HistoryArchiveFullAccess.arn
}

resource "aws_iam_role_policy_attachment" "attach_AmazonSSMManagedInstanceCore" {
  role       = aws_iam_role.LivenetNodeRole.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "attach_AmazonSSMPatchAssociation" {
  role       = aws_iam_role.LivenetNodeRole.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMPatchAssociation"
}

resource "aws_iam_instance_profile" "LivenetNodeRole" {
  name = "LivenetNodeRole"
  role = aws_iam_role.LivenetNodeRole.name
}
