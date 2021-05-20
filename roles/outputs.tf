# --- roles/outputs.tf ---
output "iam_instance_profile" {
  value = aws_iam_instance_profile.LivenetNodeRole.name
}