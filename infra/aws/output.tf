output "configure_kubectl" {
  value = module.eks_poc.configure_kubectl
}

output "cluster_connection_commands" {
  value = module.eks_poc.cluster_connection_commands
}
