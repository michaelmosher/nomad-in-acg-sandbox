resource "aws_security_group" "main" {
  name   = "${var.cluster_identifier}-load-balancer"
  vpc_id = var.vpc_id

  ingress {
    description = "Main Cluster Ingress"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.ingress_safe_list
  }

  ingress {
    description = "Nomad HTTP Ingress"
    from_port   = 4646
    to_port     = 4646
    protocol    = "tcp"
    cidr_blocks = var.ingress_safe_list
  }

  ingress {
    description = "Consul HTTP Ingress"
    from_port   = 8500
    to_port     = 8500
    protocol    = "tcp"
    cidr_blocks = var.ingress_safe_list
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.cluster_identifier}-load-balancer"
  }
}
