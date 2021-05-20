# --- region/database/locals.tf 
locals {
  name = replace(join("", [var.iso, var.domain_name]), ".", "")
}