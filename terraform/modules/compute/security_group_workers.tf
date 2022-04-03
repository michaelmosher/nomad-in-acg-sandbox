resource "aws_security_group" "cluster_workers" {
  name_prefix = "${var.cluster_identifier}-cluster-workers-"
  description = "Rules allowing access to cluster worker EC2 instances"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Allow all TCP traffic from Ingress"
    from_port       = 0
    to_port         = 65535
    protocol        = "tcp"
    cidr_blocks     = var.cluster_ingress_cidr_blocks
    security_groups = var.cluster_ingress_security_groups
  }

  ingress {
    description = "Allow all TCP traffic from other workers"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    self        = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.cluster_identifier}-cluster-workers"
  }
}
