resource "aws_iam_instance_profile" "cluster_worker" {
  name = "cluster-worker"
  role = aws_iam_role.ec2_cluster_worker.name
}

resource "aws_iam_role" "ec2_cluster_worker" {
  name               = "cluster-worker"
  assume_role_policy = data.aws_iam_policy_document.ec2_role_trust_policy.json
}

resource "aws_iam_role_policy" "worker_cloud_auto_join" {
  name   = "consul-cloud-auto-join"
  role   = aws_iam_role.ec2_cluster_worker.name
  policy = data.aws_iam_policy_document.describe_instances.json
}

resource "aws_iam_role_policy" "cts" {
  name = "cts-upate-load-balancer"
  role = aws_iam_role.ec2_cluster_worker.name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          // CRUD listener rules
          "elasticloadbalancing:CreateRule",
          "elasticloadbalancing:ModifyRule",
          "elasticloadbalancing:DeleteRule",
          // CRUD target groups
          "elasticloadbalancing:CreateTargetGroup",
          "elasticloadbalancing:ModifyTargetGroup",
          "elasticloadbalancing:DeleteTargetGroup",
          // CRUD target group attachments
          "elasticloadbalancing:RegisterTargets",
          "elasticloadbalancing:DeregisterTargets",
        ]
        Effect = "Allow"
        Resource = [
          "arn:aws:elasticloadbalancing:*:*:listener/net/*/*/*",
          "arn:aws:elasticloadbalancing:*:*:listener/app/*/*/*",
          "arn:aws:elasticloadbalancing:*:*:targetgroup/*/*",
          "arn:aws:elasticloadbalancing:*:*:listener-rule/net/*/*/*/*",
          "arn:aws:elasticloadbalancing:*:*:listener-rule/app/*/*/*/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "ec2:DescribeInstances", # you say redundant, I say independent
          "elasticloadbalancing:DescribeLoadBalancers",
          "elasticloadbalancing:DescribeLoadBalancerAttributes",
          "elasticloadbalancing:DescribeListeners",
          "elasticloadbalancing:DescribeTargetGroups",
          "elasticloadbalancing:DescribeRules",
        ]
        Resource = "*"
      }
    ]
  })
}
