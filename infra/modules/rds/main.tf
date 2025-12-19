resource "random_password" "mysql_pass" {
  length  = 24
  special = false
}

# Import existing secret
# data "aws_secretsmanager_secret" "this" {
#   name = "${var.name}-mysql-secret"
# }
# data "aws_secretsmanager_secret_version" "this" {
#   secret_id = data.aws_secretsmanager_secret.this.id
# }

resource "aws_db_instance" "mysql" {
  identifier = "${var.name}-mysql"
  allocated_storage    = var.allocated_storage
  db_name              = var.db_name
  engine               = var.engine
  engine_version       = var.engine_version
  instance_class       = var.instance_class
  username             = var.username
  password             = random_password.mysql_pass.result  
  # username = jsondecode(data.aws_secretsmanager_secret_version.this.secret_string)["username"]
  # password = jsondecode(data.aws_secretsmanager_secret_version.this.secret_string)["password"]    
  skip_final_snapshot  = var.skip_final_snapshot
  vpc_security_group_ids = var.security_group_id
  publicly_accessible   = var.publicly_accessible

}

# Create secrets in AWS Secrets Manager
resource "aws_secretsmanager_secret" "this" {
  name = "${var.name}-database-secret"
  recovery_window_in_days = 7

  tags = {
    Project = var.name
  }
}

# Update secret values
resource "aws_secretsmanager_secret_version" "this" {
  # secret_id = data.aws_secretsmanager_secret.this.id
  secret_id = aws_secretsmanager_secret.this.id

  secret_string = jsonencode({
    username = var.username
    password = random_password.mysql_pass.result  
    host     = aws_db_instance.mysql.address
    port     = var.port
    dbname   = var.db_name
  })
}


