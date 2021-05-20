# --- region/compute/variables.tf ---
variable "instance_count" {
  type = number
}
variable "volume_size" {
  type = number
}
variable "instance_type" {}
variable "iam_instance_profile" {}

variable "public_sg" {}
variable "public_subnets" {}

variable "domain_name" {}
variable "iso" {}

# --- for /etc/digitalbits.cfg ---
variable "bucket_name" {}
variable "keys" {}
variable "db_name" {}
variable "db_address" {}
variable "db_username" {}
variable "db_password" {}
variable "network_passphare" {}
variable "fee_passphrase" {}

# --- for Datadog ---
variable "dd_api_key" {}
variable "dd_site" {}