#--- root/main.tf ---
resource "aws_route53_zone" "domain_zone" {
  force_destroy = true
  name = var.domain_name
}

module "toml-certificate" {
  source           = "./toml/certificates"
  toml_zone_record = local.toml_zone_record
  zone_id          = local.zone_id

}

module "toml-cloudfront" {
  source           = "./toml/cloudfront"
  bucket_name      = local.toml_bucket_name
  org_name         = local.org_name
  domain_name      = local.domain_name
  keys             = local.keys
  zone_id          = local.zone_id
  toml_zone_record = local.toml_zone_record
  cert             = module.toml-certificate.cert
  depends_on = [
    module.certificate
  ]
}

module "certificate" {
  source              = "./certificates"
  history_zone_record = local.history_zone_record
  zone_id             = local.zone_id
  providers = {
    aws = aws.us-east-1
  }
}

module "cloudfront" {
  source              = "./cloudfront"
  bucket_name         = local.bucket_name
  zone_id             = local.zone_id
  history_zone_record = local.history_zone_record
  cert                = module.certificate.cert
  depends_on = [
    module.certificate
  ]
}

module "role" {
  source              = "./roles"
  history_archive_arn = module.cloudfront.history_archive_arn
}

# --- Frankfurt ---
module "eu-central-1" {
  source = "./region"
  # --- VPC ---
  vpc_cidr = local.vpc_cidr

  # --- DNS ---
  domain_name = local.domain_name
  zone_id     = local.zone_id
  iso         = "deu"

  # --- EC2 ---
  instance_count       = 1
  volume_size          = local.volume_size
  instance_type        = local.instance_type
  iam_instance_profile = local.iam_instance_profile

  # --- digitalbits.cfg ---
  keys              = local.keys
  bucket_name       = local.bucket_name
  network_passphare = local.network_passphare
  fee_passphrase    = local.fee_passphrase

  # --- Datadog ---
  dd_api_key = local.dd_api_key
  dd_site    = local.dd_site

  # --- RDS ---
  db_storage        = local.db_storage
  db_storage_max    = local.db_storage_max
  db_engine_version = local.db_engine_version
  instance_class    = local.instance_class
  skip_db_snapshot  = local.skip_db_snapshot

  providers = {
    aws = aws.eu-central-1
  }
}

# --- Ireland ---
module "eu-west-1" {
  source = "./region"
  # --- VPC ---
  vpc_cidr = local.vpc_cidr

  # --- DNS ---
  domain_name = local.domain_name
  zone_id     = local.zone_id
  iso         = "irl"

  # --- EC2 ---
  instance_count       = 1
  volume_size          = local.volume_size
  instance_type        = local.instance_type
  iam_instance_profile = local.iam_instance_profile

  # --- digitalbits.cfg ---
  keys              = local.keys
  bucket_name       = local.bucket_name
  network_passphare = local.network_passphare
  fee_passphrase    = local.fee_passphrase

  # --- Datadog ---
  dd_api_key = local.dd_api_key
  dd_site    = local.dd_site

  # --- RDS ---
  db_storage        = local.db_storage
  db_storage_max    = local.db_storage_max
  db_engine_version = local.db_engine_version
  instance_class    = local.instance_class
  skip_db_snapshot  = local.skip_db_snapshot

  providers = {
    aws = aws.eu-west-1
  }
}

# --- Stockholm ---
module "eu-north-1" {
  source = "./region"
  # --- VPC ---
  vpc_cidr = local.vpc_cidr

  # --- DNS ---
  domain_name = local.domain_name
  zone_id     = local.zone_id
  iso         = "swe"

  # --- EC2 ---
  instance_count       = 1
  volume_size          = local.volume_size
  instance_type        = local.instance_type
  iam_instance_profile = local.iam_instance_profile

  # --- digitalbits.cfg ---
  keys              = local.keys
  bucket_name       = local.bucket_name
  network_passphare = local.network_passphare
  fee_passphrase    = local.fee_passphrase

  # --- Datadog ---
  dd_api_key = local.dd_api_key
  dd_site    = local.dd_site

  # --- RDS ---
  db_storage        = local.db_storage
  db_storage_max    = local.db_storage_max
  db_engine_version = local.db_engine_version
  instance_class    = local.instance_class
  skip_db_snapshot  = local.skip_db_snapshot

  providers = {
    aws = aws.eu-north-1
  }
}

# --- Canada ---
module "ca-central-1" {
  source = "./region"
  # --- VPC ---
  vpc_cidr = local.vpc_cidr

  # --- DNS ---
  domain_name = local.domain_name
  zone_id     = local.zone_id
  iso         = "can"

  # --- EC2 ---
  instance_count       = 1
  volume_size          = local.volume_size
  instance_type        = local.instance_type
  iam_instance_profile = local.iam_instance_profile

  # --- digitalbits.cfg ---
  keys              = local.keys
  bucket_name       = local.bucket_name
  network_passphare = local.network_passphare
  fee_passphrase    = local.fee_passphrase

  # --- Datadog ---
  dd_api_key = local.dd_api_key
  dd_site    = local.dd_site

  # --- RDS ---
  db_storage        = local.db_storage
  db_storage_max    = local.db_storage_max
  db_engine_version = local.db_engine_version
  instance_class    = local.instance_class
  skip_db_snapshot  = local.skip_db_snapshot

  providers = {
    aws = aws.ca-central-1
  }
}