resource "aws_security_group" "gossip" {
  name_prefix = "${var.cluster_identifier}-gossip-"
  description = "Rules allowing Gossip among all cluster instances"
  vpc_id      = var.vpc_id

  ingress {
    description = "Consul Gossip (Serf) Traffic"
    from_port   = 8301
    to_port     = 8301
    protocol    = "tcp"
    self        = true
  }

  ingress {
    description = "Consul Gossip (Serf) Traffic"
    from_port   = 8301
    to_port     = 8301
    protocol    = "udp"
    self        = true
  }

  ingress {
    description = "Nomad Gossip (Serf) Traffic"
    from_port   = 4648
    to_port     = 4648
    protocol    = "tcp"
    self        = true
  }

  ingress {
    description = "Nomad Gossip (Serf) Traffic"
    from_port   = 4648
    to_port     = 4648
    protocol    = "udp"
    self        = true
  }

  tags = {
    Name = "${var.cluster_identifier}-gossip"
  }
}
