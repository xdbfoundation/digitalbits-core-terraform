output "name" {
  value = local.name
}

output "address" {
  value = aws_db_instance.main.address
}

output "username" {
  value = random_pet.random_dbusername.id
}

output "password" {
  sensitive = true
  value     = random_password.random_dbpassword.result
}