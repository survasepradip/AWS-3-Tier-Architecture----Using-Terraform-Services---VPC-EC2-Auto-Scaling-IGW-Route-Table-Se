################################################################################
# CREATING MYSQL DATABASE
################################################################################

resource "random_password" "password" {
  length  = 16
  special = false
}

resource "aws_secretsmanager_secret" "this" {
  name_prefix = "registration_app_db"
  description = "Secret to manage superuser ${var.username} password"
}

locals {
  db_secret = {
    endpoint = aws_db_instance.registration_app_db.address
    db_name  = var.db_name
    username = var.username
    password = random_password.password.result
    port     = var.port
  }
}

resource "aws_secretsmanager_secret_version" "registration_app" {
  secret_id     = aws_secretsmanager_secret.this.id
  secret_string = jsonencode(local.db_secret)
}

resource "aws_db_subnet_group" "subnet_group" {
  name       = "subnet-group"
  subnet_ids = aws_subnet.database_subnets.*.id
}

resource "aws_db_instance" "registration_app_db" {

  allocated_storage      = 10
  db_name                = var.db_name
  port                   = var.port
  engine                 = "mysql"
  instance_class         = var.instance_class
  username               = var.username
  password               = random_password.password.result
  db_subnet_group_name   = aws_db_subnet_group.subnet_group.name
  skip_final_snapshot    = true
  multi_az               = false
  vpc_security_group_ids = [aws_security_group.registration-database-sg.id]
}