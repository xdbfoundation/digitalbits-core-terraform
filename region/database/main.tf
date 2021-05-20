# --- region/database/main.tf ---
resource "random_pet" "random_dbusername" {
  length    = 4
  separator = ""
}

resource "random_string" "suffix" {
  length  = 6
  special = false
}

resource "random_password" "random_dbpassword" {
  length  = 63
  special = false
}

resource "aws_secretsmanager_secret" "dbpassword" {
  name = join("-", [join(".", [var.iso, var.domain_name]), "MasterPassword", random_string.suffix.result])
}

resource "aws_secretsmanager_secret_version" "dbpassword" {
  secret_id     = aws_secretsmanager_secret.dbpassword.id
  secret_string = random_password.random_dbpassword.result
}

resource "aws_db_instance" "main" {
  engine                = "postgres"
  engine_version        = var.db_engine_version
  allocated_storage     = var.db_storage
  max_allocated_storage = var.db_storage_max
  instance_class        = var.instance_class

  multi_az                = true
  backup_retention_period = 7

  name       = local.name
  identifier = local.name
  username   = random_pet.random_dbusername.id
  password   = random_password.random_dbpassword.result

  publicly_accessible = false
  skip_final_snapshot = var.skip_db_snapshot

  db_subnet_group_name   = var.db_subnet_group_name
  vpc_security_group_ids = var.vpc_security_group_ids

  tags = {
    Name = join(" ", [join(".", [var.iso, var.domain_name]), "RDS"])
  }
}