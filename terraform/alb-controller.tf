# The ALB Controller Helm chart is installed via CLI after the cluster is ready
# (Step 4b). Installing it here via the kubernetes provider would race against
# EKS cluster creation: the cluster takes ~15 min, which exhausts the 15-min
# STS token that TFC uses to authenticate to Kubernetes in remote runs.
#
# IAM role, policy, and Pod Identity association remain in pod-identity.tf.
