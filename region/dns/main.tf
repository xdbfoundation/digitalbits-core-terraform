# --- region/dns/main.tf
resource "aws_eip" "eip" {
  count = local.instance_count
  vpc   = true
}

resource "aws_eip_association" "ec2_eip" {
  count         = local.instance_count
  instance_id   = var.instances[count.index].id
  allocation_id = aws_eip.eip[count.index].id
}

resource "aws_route53_record" "node" {
  count   = local.instance_count
  zone_id = var.zone_id
  name    = var.instances[count.index].tags.Name
  type    = "A"
  ttl     = "300"
  records = [aws_eip.eip[count.index].public_ip]
}