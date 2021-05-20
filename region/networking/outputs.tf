# --- region/networking/outputs.tf ---
output "vpc_id" {
  value = aws_vpc.livenet_vpc.id
}

output "db_subnet_group_name" {
  value = aws_db_subnet_group.livenet_rds_subnetgroup.name
}

output "rds_sg" {
  value = aws_security_group.rds_sg
}

output "public_sg" {
  value = aws_security_group.livenet_sg
}

output "public_subnets" {
  value = aws_subnet.livenet_public_subnet.*.id
}

output "private_subnets" {
  value = aws_subnet.livenet_private_subnet.*.id
}