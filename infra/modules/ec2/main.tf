resource "aws_instance" "this" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = var.vpc_security_group_ids
  availability_zone      = var.availability_zone
  iam_instance_profile   = var.iam_instance_profile

  dynamic "root_block_device" {
    for_each = var.root_block_device == null ? [] : [var.root_block_device]
    content {
      volume_size           = root_block_device.value.volume_size
      volume_type           = root_block_device.value.volume_type
      delete_on_termination = root_block_device.value.delete_on_termination
    }
  }

  user_data = var.user_data

  tags = {
    Name    = var.name
    Project = var.project
    os = lower(var.os)
  }
}
