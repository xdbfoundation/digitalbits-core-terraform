# --- region/lb/locals.tf ---
locals {
  instance_count = length(var.instances)
}