# resource "random_password" "mysql_pass" {
#   length  = 24
#   special = false
# }

resource "aws_db_instance" "mysql" {
  identifier = "${var.projectName}-mysql"
  allocated_storage    = 10
  db_name              = "appdb"
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t4g.micro"
  # username             = "rds_username"
  # password = random_password.mysql_pass.result
  skip_final_snapshot  = true
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  publicly_accessible   = true

  username = jsondecode(
          data.aws_secretsmanager_secret_version.mysql.secret_string
        )["username"]

  password = jsondecode(
          data.aws_secretsmanager_secret_version.mysql.secret_string
        )["password"]

}

data "aws_secretsmanager_secret" "mysql" {
  name = "${var.projectName}-mysql-secret"
}

data "aws_secretsmanager_secret_version" "mysql" {
  secret_id = data.aws_secretsmanager_secret.mysql.id
}


# resource "aws_secretsmanager_secret" "mysql_secret" {
#   name = "${var.projectName}-mysql-secret"
#   recovery_window_in_days = 7

#   lifecycle {
#     prevent_destroy = true
#   }
  
#   tags = {
#     Project = var.projectName
#   }
# }

# resource "aws_secretsmanager_secret_version" "mysql_secret_version" {
#   secret_id = aws_secretsmanager_secret.mysql_secret.id

#   secret_string = jsonencode({
#     username = "rds_username"
#     password = random_password.mysql_pass.result
#     host     = aws_db_instance.mysql.address
#     port     = 3306
#     dbname   = "appdb"
#   })
# }


