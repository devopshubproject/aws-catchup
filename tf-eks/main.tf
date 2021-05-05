
provider "aws" {
  region  = "us-east-2"
  version = ">= 2.38.0"
}

data "aws_region" "region" {}

data "aws_availability_zones" "az" {}



resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"

  tags = map(
    "Name", "terraform-eks-demo-node",
    "kubernetes.io/cluster/${params.cluster}", "shared",
  )
}

resource "aws_subnet" "subnet" {
  count = 2

  availability_zone = data.aws_availability_zones.az.names[count.index]
  cidr_block        = "10.0.${count.index}.0/24"
  vpc_id            = aws_vpc.vpc.id
  map_public_ip_on_launch = true

  tags = map(
    "Name", "terraform-eks-demo-node",
    "kubernetes.io/cluster/${params.cluster}", "shared",
  )
}

resource "aws_internet_gateway" "igate" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "terraform-eks-demo"
  }
}

resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.demo.id
  }
}

resource "aws_route_table_association" "rta" {
  count = 2

  subnet_id      = aws_subnet.subnet.*.id[count.index]
  route_table_id = aws_route_table.rt.id
}


resource "aws_iam_role" "role" {
  name = "terraform-eks-role"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "clusterpolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.role.name
}

resource "aws_iam_role_policy_attachment" "servicepolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.role.name
}

resource "aws_security_group" "sg" {
  name        = "terraform-eks-sg"
  description = "Cluster communication with worker nodes"
  vpc_id      = aws_vpc.vpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "terraform-eks-sg"
  }
}

resource "aws_security_group_rule" "sg_rule" {
  cidr_blocks       = [local.workstation-external-cidr]
  description       = "Allow workstation to communicate with the cluster API Server"
  from_port         = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.sg.id
  to_port           = 443
  type              = "ingress"
}

resource "aws_eks_cluster" "eks" {
  name     = var.cluster-name
  role_arn = aws_iam_role.role.arn

  vpc_config {
    security_group_ids = [aws_security_group.sg.id]
    subnet_ids         = aws_vpc.subnet[*].id
  }

  depends_on = [
    aws_iam_role_policy_attachment.clusterpolicy,
    aws_iam_role_policy_attachment.servicepolicy,
  ]
}

resource "aws_iam_role" "role" {
  name = "terraform-eks-node"

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

resource "aws_iam_role_policy_attachment" "nodepolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.node.name
}

resource "aws_iam_role_policy_attachment" "cnipolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.node.name
}

resource "aws_iam_role_policy_attachment" "ecrpolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.node.name
}

resource "aws_eks_node_group" "node" {
  cluster_name    = aws_eks_cluster.eks.name
  node_group_name = "laya"
  node_role_arn   = aws_iam_role.node.arn
  subnet_ids      = aws_vpc.subnet[*].id

  scaling_config {
    desired_size = 2
    max_size     = 2
    min_size     = 1
  }

  depends_on = [
    aws_iam_role_policy_attachment.nodepolicy,
    aws_iam_role_policy_attachment.cnipolicy,
    aws_iam_role_policy_attachment.ecrpolicy,
  ]
}