# Public IPs
output "ansible_public_ip" {
  description = "Public IP of the Ansible"
  value       = aws_instance.ansible_ec2.public_ip
}

# Private IPs 
output "flask_private_ip" {
  description = "Private IP of the Python Flask EC2"
  value       = aws_instance.python_flask.private_ip
}

# Ansible Inventory File
resource "local_file" "python_flask" {
  filename = "../ansible/inventory"

  content = templatefile("${path.module}/templates/inventory.tmpl", {
    python_ip  = aws_instance.python_flask.private_ip
    python_ip_public  = aws_instance.python_flask.public_ip
    python_user  = var.ansibleUserByOS[aws_instance.python_flask.tags.os]

    clientkey  = aws_key_pair.monitoringKeypair.key_name
    
    depends_on = [
    aws_instance.python_flask,
  ]
  })
}

# Deployment script for Ansible
resource "local_file" "ansible_deployment" {
  filename = "../${var.deployName}"

  content = templatefile("${path.module}/templates/deploy.tmpl", {
    ansible_ip       = aws_instance.ansible_ec2.public_ip
    ansible_user     = var.ansibleUserByOS[aws_instance.ansible_ec2.tags.os]
    clientkey        = "${aws_key_pair.monitoringKeypair.key_name}.pem"
  })
}

# output "db_secret_arn" {
#   value = aws_db_instance.mysql.master_user_secret[0].secret_arn
# }

# output "db_endpoint" {
#   value = aws_db_instance.mysql.address
# }

# # Flask.service script for Ansible 
# resource "local_file" "flask_service_variables" {
#   filename = "${path.root}/../ansible/roles/app/templates/flask.service.j2"

#   content = templatefile("${path.module}/templates/flask_service.tmpl", {
#     db_secret_arn       = aws_db_instance.mysql.master_user_secret[0].secret_arn
#     aws_region     = var.region
#   })
# }