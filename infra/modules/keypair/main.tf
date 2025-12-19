resource "tls_private_key" "this" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "this" {
  key_name   = "${var.project_name}-client-key"
  public_key = tls_private_key.this.public_key_openssh
}

resource "local_file" "private_key" {
  filename        = "${var.output_path}/${aws_key_pair.this.key_name}.pem"
  content         = tls_private_key.this.private_key_pem
  file_permission = "0400"
}
