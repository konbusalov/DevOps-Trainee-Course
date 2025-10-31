data "aws_ami" "ubuntu" {
    owners = ["099720109477"]
    most_recent = true

    filter {
        name = "name"
        values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
    }
}

data "aws_caller_identity" "account" {}

data "aws_region" "current" {}

data "aws_iam_policy_document" "aws_lbc" {
    statement {
      effect = "Allow"

      principals {
        type = "Service"
        identifiers = ["pods.eks.amazonaws.com"]
      }

      actions = [
        "sts:AssumeRole",
        "sts:TagSession"
      ]
    }
}

data "aws_availability_zones" "available_azs" {}

locals {
    azs = slice(data.aws_availability_zones.available_azs.names, 0, 3)
    cluster-name = "${var.project-name}-cluster"
}

module "vpc" {
    source = "./modules/vpc"
    name_prefix = "${var.project-name}"
    azs = local.azs
    vpc_cidr = "10.0.0.0/16"
    public_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
    private_subnets = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]

    enable_nat_gateway = true

    public_subnet_tags = {
        "kubernetes.io/role/elb" = 1
    }

    private_subnet_tags = {
        "kubernetes.io/role/internal-elb" = 1
    }
}

module "eks" {
    source  = "terraform-aws-modules/eks/aws"
    version = "20.8.5"

    cluster_name    = local.cluster-name
    cluster_version = "1.29"

    cluster_endpoint_public_access           = true
    enable_cluster_creator_admin_permissions = true

    vpc_id     = module.vpc.vpc_id
    subnet_ids = module.vpc.private_subnet_ids

    eks_managed_node_group_defaults = {
        ami_type = "AL2_x86_64"
    }

    eks_managed_node_groups = {
        one = {
            name = "node-group-1"

            instance_types = ["t3.small"]

            min_size     = 1
            max_size     = 3
            desired_size = 2
        }   

        two = {
            name = "node-group-2"

            instance_types = ["t3.small"]

            min_size     = 1
            max_size     = 2
            desired_size = 1
        }
    }
}

resource "aws_iam_role" "aws_lbc" {
    name_prefix = "${local.cluster-name}-aws-lbc-"
    assume_role_policy = data.aws_iam_policy_document.aws_lbc.json
}

resource "aws_iam_policy" "aws_lbc" {
    policy = file("./iam/AWSLoadBalancerController.json")
    name = "AWSLoadBalancerController"
}

resource "aws_iam_role_policy_attachment" "aws_lbc" {
    policy_arn = aws_iam_policy.aws_lbc.arn
    role = aws_iam_role.aws_lbc.name
}

resource "aws_eks_pod_identity_association" "aws_lbc" {
    cluster_name = local.cluster-name
    namespace = "kube-system"
    service_account = "aws-load-balancer-controller"
    role_arn = aws_iam_role.aws_lbc.arn

    depends_on = [ module.eks ]
}

resource "helm_release" "aws_lbc" {
    name = "aws-load-balancer-controller"

    repository = "https://aws.github.io/eks-charts"
    chart = "aws-load-balancer-controller"
    namespace = "kube-system"
    version = "1.7.2"

    set = [ 
        {
            name = "clusterName"
            value = local.cluster-name
        },
        {
            name = "serviceAccount.name"
            value = "aws-load-balancer-controller"
        } 
    ]
}

resource "aws_eks_addon" "pod_identity_agent" {
  cluster_name = local.cluster-name
  addon_name   = "eks-pod-identity-agent"

  depends_on = [module.eks]
}


  
