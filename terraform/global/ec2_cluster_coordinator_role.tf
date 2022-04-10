resource "aws_iam_instance_profile" "cluster_coordinator" {
  name = "cluster-coordinator"
  role = aws_iam_role.ec2_cluster_coordinator.name
}

resource "aws_iam_role" "ec2_cluster_coordinator" {
  name               = "cluster-coordinator"
  assume_role_policy = data.aws_iam_policy_document.ec2_role_trust_policy.json
}

resource "aws_iam_role_policy" "coordinator_cloud_auto_join" {
  name   = "consul-cloud-auto-join"
  role   = aws_iam_role.ec2_cluster_coordinator.name
  policy = data.aws_iam_policy_document.describe_instances.json
}
