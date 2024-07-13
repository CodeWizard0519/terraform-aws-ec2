#
# EKS Worker Nodes Resources
#  * IAM role allowing Kubernetes actions to access other AWS services
#  * EKS Node Group to launch worker nodes
#

resource "aws_iam_role" "eks-node-role" {
  name = "${var.cluster_name}-workernode-role"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "eks-node-role-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks-node-role.name
}

resource "aws_iam_role_policy_attachment" "eks-node-role-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks-node-role.name
}

resource "aws_iam_role_policy_attachment" "eks-node-role-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks-node-role.name
}

resource "aws_iam_role_policy_attachment" "eks-node-role-AmazonEBSCSIDriverPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  role       = aws_iam_role.eks-node-role.name
}

resource "aws_eks_node_group" "eks-ng" {
  cluster_name    = aws_eks_cluster.eks-cluster.name
  node_group_name = "${var.cluster_name}-ng"
  node_role_arn   = aws_iam_role.eks-node-role.arn
  subnet_ids      = aws_subnet.eks-subnet[*].id
  disk_size       = "${var.disk_size}"
  instance_types  = ["${var.instance_types}"]

  scaling_config {
    desired_size = 3
    max_size     = 3
    min_size     = 3
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks-node-role-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.eks-node-role-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.eks-node-role-AmazonEC2ContainerRegistryReadOnly,
    aws_iam_role_policy_attachment.eks-node-role-AmazonEBSCSIDriverPolicy,
    aws_eks_cluster.eks-cluster,
  ]
}

resource "aws_eks_addon" "eks-ebs-csi" {
  cluster_name = aws_eks_cluster.eks-cluster.name
  addon_name   = "aws-ebs-csi-driver"
  depends_on = [
    aws_iam_role_policy_attachment.eks-node-role-AmazonEBSCSIDriverPolicy,
    aws_eks_node_group.eks-ng,
  ]
}

resource "aws_eks_addon" "eks-coredns" {
  cluster_name = aws_eks_cluster.eks-cluster.name
  addon_name   = "coredns"
  depends_on = [
    aws_iam_role_policy_attachment.eks-node-role-AmazonEBSCSIDriverPolicy,
    aws_eks_node_group.eks-ng,
  ]
}

resource "aws_eks_addon" "eks-kube-proxy" {
  cluster_name = aws_eks_cluster.eks-cluster.name
  addon_name   = "kube-proxy"
  depends_on = [
    aws_iam_role_policy_attachment.eks-node-role-AmazonEBSCSIDriverPolicy,
    aws_eks_node_group.eks-ng,
  ]
}

resource "aws_eks_addon" "eks-vpc-cni" {
  cluster_name = aws_eks_cluster.eks-cluster.name
  addon_name   = "vpc-cni"
  depends_on = [
    aws_iam_role_policy_attachment.eks-node-role-AmazonEBSCSIDriverPolicy,
    aws_eks_node_group.eks-ng,
  ]
}
