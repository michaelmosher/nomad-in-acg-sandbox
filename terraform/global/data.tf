data "aws_iam_policy_document" "ec2_role_trust_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "describe_instances" {
  statement {
    actions   = ["ec2:DescribeInstances"]
    resources = ["*"]
  }
}
