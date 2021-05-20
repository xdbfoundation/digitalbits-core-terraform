# --- region/compute/main.tf ---
resource "aws_instance" "livenet_node" {
  count = var.instance_count
  ami   = data.aws_ami.server_ami.id

  instance_type        = var.instance_type
  iam_instance_profile = var.iam_instance_profile
  volume_tags          = {}

  root_block_device {
    volume_size = var.volume_size
  }

  user_data = templatefile("${path.module}/user_data.tpl", {
    hostname          = join(".", [join("-", [var.iso, count.index + 1]), var.domain_name])
    iso               = var.iso
    node              = var.keys[var.iso]
    db_name           = var.db_name
    db_address        = var.db_address
    db_username       = var.db_username
    db_password       = var.db_password
    network_passphare = var.network_passphare
    fee_passphrase    = var.fee_passphrase
    domain_name       = var.domain_name,
    known_peers       = jsonencode([for k, v in var.keys : join(".", [join("-", [k, 1]), var.domain_name]) if k != var.iso])
    bucket_name       = var.bucket_name
    validators        = { for k, v in var.keys : k => v if k != var.iso }
    dd_api_key        = var.dd_api_key
    dd_site           = var.dd_site
  })

  lifecycle {
    ignore_changes = [
      ami,
      volume_tags,
      root_block_device
    ]
  }

  vpc_security_group_ids = [var.public_sg]
  subnet_id              = var.public_subnets[count.index]

  tags = {
    Name = join(".", [join("-", [var.iso, count.index + 1]), var.domain_name])
  }
}