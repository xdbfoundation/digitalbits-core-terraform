# --- region/dns/locals.tf ---
locals {
  instance_count = length(var.instances)
}