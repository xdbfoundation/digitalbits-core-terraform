# --- region/compute/outputs.tf ---
output "instances" {
  sensitive = true
  value     = aws_instance.livenet_node
}