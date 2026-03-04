############################################
# DATA SOURCES
############################################

# Get Default VPC
data "aws_vpc" "default" {
  default = true
}

# Get All Subnets in Default VPC (Dev Setup)
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

############################################
# IAM ROLE - EKS CONTROL PLANE
############################################

resource "aws_iam_role" "eks_cluster_role" {
  name = "dev-eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "eks.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })

  tags = {
    Environment = "Development"
  }
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

############################################
# EKS CLUSTER
############################################

resource "aws_eks_cluster" "dev_cluster" {
  name     = "dev-eks-cluster"
  role_arn = aws_iam_role.eks_cluster_role.arn
  version  = "1.29"

  vpc_config {
    subnet_ids = data.aws_subnets.default.ids
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy
  ]

  tags = {
    Environment = "Development"
  }
}

############################################
# IAM ROLE - WORKER NODES
############################################

resource "aws_iam_role" "eks_node_role" {
  name = "dev-eks-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })

  tags = {
    Environment = "Development"
  }
}

# Attach Required Policies to Worker Nodes
resource "aws_iam_role_policy_attachment" "worker_node_policy" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "worker_cni_policy" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "worker_ecr_policy" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

############################################
# MANAGED NODE GROUP
############################################

resource "aws_eks_node_group" "dev_node_group" {
  cluster_name    = aws_eks_cluster.dev_cluster.name
  node_group_name = "dev-node-group"
  node_role_arn   = aws_iam_role.eks_node_role.arn
  subnet_ids      = data.aws_subnets.default.ids

  instance_types = ["t3.medium"]

  scaling_config {
    desired_size = 1
    min_size     = 1
    max_size     = 2
  }

  depends_on = [
    aws_iam_role_policy_attachment.worker_node_policy,
    aws_iam_role_policy_attachment.worker_cni_policy,
    aws_iam_role_policy_attachment.worker_ecr_policy
  ]

  tags = {
    Environment = "Development"
  }
}

############################################
# S3 BUCKET FOR TERRAFORM STATE
############################################
resource "aws_s3_bucket" "eks_state" {
  bucket = "eks-terraform-state-vaibh-2026"
  acl    = "private"
  tags = {
    Name        = "EKS Terraform State"
    Environment = "Dev"
  }
}