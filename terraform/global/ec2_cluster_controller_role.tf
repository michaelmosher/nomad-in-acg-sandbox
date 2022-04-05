resource "aws_iam_instance_profile" "cluster_controller" {
  name = "cluster-controller"
  role = aws_iam_role.ec2_cluster_controller.name
}

resource "aws_iam_role" "ec2_cluster_controller" {
  name               = "cluster-controller"
  assume_role_policy = data.aws_iam_policy_document.ec2_role_trust_policy.json
}

resource "aws_iam_role_policy" "controller_cloud_auto_join" {
  name   = "consul-cloud-auto-join"
  role   = aws_iam_role.ec2_cluster_controller.name
  policy = data.aws_iam_policy_document.describe_instances.json
}
