###############################################
# Terraform – Amazon EKS Cluster (Human Version)
# Clean, readable, interview-friendly code
###############################################

terraform {
  required_version = ">= 1.3.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "ap-south-1"      # Mumbai region
}

###############################################
# 1. VPC + Subnets + Networking
###############################################

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.0.0"

  name = "eks-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["ap-south-1a", "ap-south-1b"]
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets = ["10.0.3.0/24", "10.0.4.0/24"]

  enable_nat_gateway = true
}

###############################################
# 2. EKS Cluster
###############################################

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.8.3"

  cluster_name    = "my-eks-cluster"
  cluster_version = "1.29"

  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = module.vpc.private_subnets
  cluster_endpoint_public_access = true

  enable_irsa = true   # Enables IAM roles for service accounts

  #############################################
  # Node Group
  #############################################
  eks_managed_node_groups = {
    default = {
      min_size     = 1
      max_size     = 3
      desired_size = 2

      instance_types = ["t3.medium"]
    }
  }
}

###############################################
# 3. Outputs
###############################################

output "cluster_name" {
  description = "EKS Cluster name"
  value       = module.eks.cluster_name
}

output "kubeconfig" {
  description = "Cluster kubeconfig"
  value       = module.eks.kubeconfig
}

output "cluster_endpoint" {
  description = "API endpoint"
  value       = module.eks.cluster_endpoint
}
