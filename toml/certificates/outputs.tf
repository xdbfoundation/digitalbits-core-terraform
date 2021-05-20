# --- toml/certificates/outputs.tf
output "cert" {
  value = aws_acm_certificate.cert
}