provider "aws" {
  region = "us-east-1"
}

module "eks_poc" {
  source = "git::https://github.com/rafaelhueb92/terraform-module-eks-poc.git?ref=master"

  cluster_name       = "kafka-cluster"
  kubernetes_version = "1.36"

  node_instance_type = "t3.medium"
  node_capacity_type = "ON_DEMAND"
  node_desired_size  = 2
  node_min_size      = 1
  node_max_size      = 4
  node_disk_size     = 20

  install_argocd     = true
  install_monitoring = false

  argocd_application_manifests = [
    {
      apiVersion = "argoproj.io/v1alpha1"
      kind       = "Application"
      metadata = {
        name      = "kafka"
        namespace = "argocd"
      }
      spec = {
        project = "default"
        source = {
          repoURL        = "https://github.com/rafaelhueb92/eks-kafka.git"
          targetRevision = "master"
          path           = "manifests"
        }
        destination = {
          server    = "https://kubernetes.default.svc"
          namespace = "kafka"
        }
        syncPolicy = {
          syncOptions = ["CreateNamespace=true"]
          automated = {
            prune    = true
            selfHeal = true
          }
        }
      }
    }
  ]

  additional_admin_arns = [
  ]

  tags = {
    Environment = "dev"
    Team        = "platform"
  }
}

