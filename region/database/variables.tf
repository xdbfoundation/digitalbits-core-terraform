# --- region/database/variables.tf ---
variable "db_storage" {}
variable "db_storage_max" {}
variable "db_engine_version" {}
variable "instance_class" {}
variable "skip_db_snapshot" {}

variable "db_subnet_group_name" {}
variable "vpc_security_group_ids" {}

variable "domain_name" {}
variable "iso" {}