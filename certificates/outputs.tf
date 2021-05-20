# --- certificates/outputs.tf
output "cert" {
  sensitive = true
  value     = aws_acm_certificate.cert
}