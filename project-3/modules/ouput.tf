output "cluster_name" {
  value = module.eks.cluster_name
}

output "cluster_primary_security_group_id" {
  value = module.eks.cluster_primary_security_group_id
}

output "aws_sts_calleridentity" {
  value = data.aws_caller_identity.current
}


output "oidc_provider_arn" {
  description = "The ARN of the OIDC Provider if `enable_irsa = true`"
  value       = module.eks.oidc_provider_arn
}

################################################################################
# IAM Role
################################################################################

output "cluster_iam_role_name" {
  description = "IAM role name of the EKS cluster"
  value       = module.eks.cluster_iam_role_name
}

output "cluster_iam_role_arn" {
  description = "IAM role ARN of the EKS cluster"
  value       = module.eks.cluster_iam_role_arn
}
################################################################################
# Karpenter controller IAM Role
################################################################################

output "karpenter_iam_role_name" {
  description = "The name of the controller IAM role"
  value       = module.karpenter.iam_role_name
}

output "karpenter_iam_role_arn" {
  description = "The Amazon Resource Name (ARN) specifying the controller IAM role"
  value       = module.karpenter.iam_role_arn
}
################################################################################
# Node Termination Queue
################################################################################

output "karpenter_queue_arn" {
  description = "The ARN of the SQS queue"
  value       = module.karpenter.queue_arn
}

output "karpenter_queue_name" {
  description = "The name of the created Amazon SQS queue"
  value       = module.karpenter.queue_name
}

################################################################################
# Node IAM Role
################################################################################

output "karpenter_node_iam_role_name" {
  description = "The name of the IAM role"
  value       = module.karpenter.node_iam_role_name
}

output "karpenter_node_iam_role_arn" {
  description = "The Amazon Resource Name (ARN) specifying the IAM role"
  value       = module.karpenter.node_iam_role_arn
}


################################################################################
# Node IAM Instance Profile
################################################################################

output "karpenter_instance_profile_arn" {
  description = "ARN assigned by AWS to the instance profile"
  value       = module.karpenter.instance_profile_arn
}
