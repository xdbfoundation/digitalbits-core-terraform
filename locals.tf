# --- root/locals.tf ---
locals {
  # --- VPC ---
  vpc_cidr = "10.0.0.0/16"

  # --- EC2 ---
  volume_size          = 40
  instance_type        = "m5.large"
  iam_instance_profile = module.role.iam_instance_profile

  # --- RDS ---
  db_storage        = 80
  db_storage_max    = 1000
  db_engine_version = "12.13"
  instance_class    = "db.t3.medium"
  skip_db_snapshot  = true

  # --- Route53 ---
  domain_name = var.domain_name
  zone_id     = aws_route53_zone.domain_zone.zone_id
  history_zone_record = join(".", ["history", local.domain_name])

  # --- CloudFront ---
  bucket_name = join("-", ["livenet-history", random_string.suffix.result])
}

resource "random_string" "suffix" {
  length  = 6
  upper   = false
  special = false
}

# --- for digitalbits.cfg ---
locals {
  network_passphare = "LiveNet Global DigitalBits Network ; February 2021"
  fee_passphrase    = "LiveNet DigitalBits Fee Pool ; February 2021"
  keys = {
    "deu" = {
      secret_seed  = var.secret_deu
      display_name = join(" ", [local.org_name, "Germany"])
      public       = "GDY2Z2A7R77ZJLZLUGSKKFKIJKCRNODX6CG76TNKEET6VTBBQ7E66G5Y"
      history      = "https://${local.history_zone_record}/livenet/deu/"
      history_get  = "curl -sf https://${local.history_zone_record}/livenet/deu/{0} -o {1}"
      history_put  = "aws s3 cp {0} s3://${local.bucket_name}/livenet/deu/{1} --region us-east-1"
    }
    "irl" = {
      secret_seed  = var.secret_irl
      display_name = join(" ", [local.org_name, "Ireland"])
      public       = "GAGHT5ILATKDWH7KALROAANBOPIT4TVVRZ4IOKVMHGYSSLIGF4YCY5NR"
      history      = "https://${local.history_zone_record}/livenet/irl/"
      history_get  = "curl -sf https://${local.history_zone_record}/livenet/irl/{0} -o {1}"
      history_put  = "aws s3 cp {0} s3://${local.bucket_name}/livenet/irl/{1} --region us-east-1"
    }
    "swe" = {
      secret_seed  = var.secret_swe
      display_name = join(" ", [local.org_name, "Sweden"])
      public       = "GCIR2V3RLOTDY62STYQLX6VON3ZOBGN7JZ252PVB32VWM5KKMAAGTSPF"
      history      = "https://${local.history_zone_record}/livenet/swe/"
      history_get  = "curl -sf https://${local.history_zone_record}/livenet/swe/{0} -o {1}"
      history_put  = "aws s3 cp {0} s3://${local.bucket_name}/livenet/swe/{1} --region us-east-1"
    }
    "can" = {
      secret_seed  = var.secret_can
      display_name = join(" ", [local.org_name, "Canada"])
      public       = "SAEJDFFDVM2T4YOG57OQXCK7QLPRWIYVQWMYRGCWZH7JNIBIUTRHUOVL"
      history      = "https://${local.history_zone_record}/livenet/can/"
      history_get  = "curl -sf https://${local.history_zone_record}/livenet/can/{0} -o {1}"
      history_put  = "aws s3 cp {0} s3://${local.bucket_name}/livenet/can/{1} --region us-east-1"
    }
  }
}

# --- toml ---
locals {
  toml_bucket_name = join("-", [local.domain_name, "digitalbits.toml"])
  toml_zone_record = local.domain_name
  org_name         = "Test"
}