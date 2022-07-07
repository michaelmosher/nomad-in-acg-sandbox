resource "aws_instance" "cluster_worker" {
  ami                  = data.aws_ami.ubuntu_22_04.id
  iam_instance_profile = var.worker_instance_profile
  instance_type        = var.worker_instance_type
  user_data            = var.worker_user_data

  subnet_id = element(
    [for s in var.cluster_subnet_ids : s], # turn set into ordered list
    count.index % length(var.cluster_subnet_ids)
  )

  vpc_security_group_ids = [
    aws_security_group.cluster_workers.id,
    aws_security_group.gossip.id,
  ]

  tags = {
    Name             = format("%s-worker-%d", var.cluster_identifier, count.index + 1)
    ConsulDatacenter = var.cluster_identifier
  }

  lifecycle {
    ignore_changes = [ami]
  }

  count = var.worker_instance_count
}
