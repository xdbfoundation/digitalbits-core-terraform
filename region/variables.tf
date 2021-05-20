# --- region/variables.tf ---

# --- VPC ---
variable "vpc_cidr" {}

# --- EC2 ---
variable "instance_count" {
  type = number
}
variable "volume_size" {
  type = number
}
variable "instance_type" {
  type = string
}
variable "iam_instance_profile" {
  type = string
}
# --- digitalbits.cfg ---
variable "network_passphare" {}
variable "fee_passphrase" {}
variable "keys" {}
variable "bucket_name" {}

variable "dd_api_key" {}
variable "dd_site" {}

# --- DNS ---
variable "iso" {}
variable "domain_name" {}
variable "zone_id" {}

# --- RDS ---
variable "db_storage" {}
variable "db_storage_max" {}
variable "db_engine_version" {}
variable "instance_class" {}
variable "skip_db_snapshot" {}

