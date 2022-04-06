resource "aws_efs_file_system" "this" {
  encrypted = true

  tags = {
    Name = local.app_name
  }
}

resource "aws_efs_mount_target" "this" {
  for_each = toset(data.aws_subnets.private.ids)

  file_system_id  = aws_efs_file_system.this.id
  subnet_id       = each.value
  security_groups = [aws_security_group.efs.id]
}

resource "aws_security_group" "efs" {
  name        = "${local.app_name}-efs"
  description = "Rules allowing access to EFS filesystem"
  vpc_id      = data.aws_vpc.main.id

  ingress {
    description     = "NFS from instance security group"
    from_port       = 2049
    to_port         = 2049
    protocol        = "tcp"
    security_groups = [data.aws_security_group.workers.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${local.app_name}-efs"
  }
}
