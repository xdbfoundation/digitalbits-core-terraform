# --- region/main.tf ---
module "networking" {
  source = "./networking"

  vpc_cidr = var.vpc_cidr

  public_sn_count  = 3
  private_sn_count = 3
  max_subnets      = 20

  public_cidrs  = [for i in range(2, 255, 2) : cidrsubnet(var.vpc_cidr, 8, i)]
  private_cidrs = [for i in range(1, 255, 2) : cidrsubnet(var.vpc_cidr, 8, i)]
}

module "database" {
  source = "./database"

  db_storage        = var.db_storage
  db_storage_max    = var.db_storage_max
  db_engine_version = var.db_engine_version
  instance_class    = var.instance_class
  skip_db_snapshot  = var.skip_db_snapshot

  db_subnet_group_name   = module.networking.db_subnet_group_name
  vpc_security_group_ids = [module.networking.rds_sg.id]

  iso         = var.iso
  domain_name = var.domain_name
}

module "compute" {
  depends_on = [
    module.database
  ]
  source = "./compute"

  instance_count       = var.instance_count
  volume_size          = var.volume_size
  instance_type        = var.instance_type
  iam_instance_profile = var.iam_instance_profile

  public_sg      = module.networking.public_sg.id
  public_subnets = module.networking.public_subnets

  iso         = var.iso
  domain_name = var.domain_name

  # --- for /etc/digitalbits.cfg ---
  keys              = var.keys
  db_name           = module.database.name
  db_address        = module.database.address
  db_username       = module.database.username
  db_password       = module.database.password
  network_passphare = var.network_passphare
  fee_passphrase    = var.fee_passphrase
  bucket_name       = var.bucket_name
  dd_api_key        = var.dd_api_key
  dd_site           = var.dd_site
}

module "dns" {
  source = "./dns"

  zone_id   = var.zone_id
  instances = module.compute.instances
}