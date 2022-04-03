resource "aws_security_group" "cluster_controllers" {
  name_prefix = "${var.cluster_identifier}-cluster-controllers-"
  description = "Rules allowing access to cluster controller EC2 instances"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Consul RPC Traffic"
    from_port       = 8300
    to_port         = 8300
    protocol        = "tcp"
    security_groups = [aws_security_group.gossip.id]
  }

  ingress {
    description     = "Nomad RPC Traffic"
    from_port       = 4647
    to_port         = 4647
    protocol        = "tcp"
    security_groups = [aws_security_group.gossip.id]
  }

  ingress {
    description     = "Allow Nomad HTTP from Ingress"
    from_port       = 4646
    to_port         = 4646
    protocol        = "tcp"
    cidr_blocks     = var.cluster_ingress_cidr_blocks
    security_groups = var.cluster_ingress_security_groups
  }

  ingress {
    description     = "Allow Consul HTTP from Ingress"
    from_port       = 8500
    to_port         = 8500
    protocol        = "tcp"
    cidr_blocks     = var.cluster_ingress_cidr_blocks
    security_groups = var.cluster_ingress_security_groups
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "cluster-controllers-${var.cluster_identifier}"
  }
}
