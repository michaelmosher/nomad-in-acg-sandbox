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
