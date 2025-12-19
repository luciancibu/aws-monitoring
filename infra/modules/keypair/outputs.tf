output "key_name" {
  value       = aws_key_pair.this.key_name
}

output "public_key" {
  value = tls_private_key.this.public_key_openssh
}
