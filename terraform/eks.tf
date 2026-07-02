module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  cluster_endpoint_public_access = true

  eks_managed_node_groups = {
    default = {
      ami_type       = "AL2023_x86_64_STANDARD"
      instance_types = [var.node_instance_type]
      min_size       = 1
      max_size       = 16
      desired_size   = var.desired_nodes

      # For AL2023, we use cloudinit_pre_nodeadm to configure the Kubelet config natively
      cloudinit_pre_nodeadm = [
        {
          content_type = "application/node.eks.aws"
          content      = <<-EOT
            ---
            apiVersion: node.eks.aws/v1alpha1
            kind: NodeConfig
            spec:
              kubelet:
                config:
                  maxPods: 11
          EOT
        }
      ]
    }
  }

  cluster_addons = {
    coredns                = {}
    kube-proxy             = {}
    vpc-cni = {
      # Enable Prefix Delegation to give each ENI more IP addresses
      configuration_values = jsonencode({
        env = {
          ENABLE_PREFIX_DELEGATION = "true"
          WARM_PREFIX_TARGET       = "1"
        }
      })
    }
    eks-pod-identity-agent = {}
  }

  enable_cluster_creator_admin_permissions = true
  enable_irsa                              = true

  tags = { Project = "FifaApp" }
}
