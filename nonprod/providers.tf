terraform {
  required_version = ">= 1.2.0"

  required_providers {
    oci = {
      source  = "hashicorp/oci"
      version = ">= 4.0.0"
    }
    # kubernetes = {
    #   source  = "hashicorp/kubernetes"
    #   version = "~> 2.0"
    # }
    # tls = {
    #   source  = "hashicorp/tls"
    #   version = "~> 3.0"
    # }
  }
}

locals {
#   # THIS MUST BE UPDATED IF COPIED
#   aws_provider_assume_role_arn = "arn:aws:iam::941986904600:role/OrganizationAccountAccessRole"
#   aws_region                   = "us-west-2"

#   kubernetes_provider_command_args = [
#     "eks", "get-token",
#     "--region", local.aws_region,
#     "--cluster-name", module.platform.eks_cluster_id,
#     "--role-arn", local.aws_provider_assume_role_arn,
#   ]

  compartment_ocid = "ocid1.tenancy.oc1..aaaaaaaafnc4ezkn7qo5neppywgy6hxgxyi7fgsjxo5n5e2wgxh7hviwh26a"
  user_ocid = "ocid1.user.oc1..aaaaaaaa36urghdanx4ppp2krccywzye6vvwpr4axyftbuwzr6jliu2ukmwa"

#  global_tags = {
#    "env" = "nonprod"
#  }
}

provider "oci" {
  tenancy_ocid = local.compartment_ocid
  user_ocid = local.user_ocid
  private_key_path = "/home/todhansmann/.oci/pjnp.pem"
  fingerprint = "d1:0f:57:3b:25:37:2f:86:ec:7f:ff:69:f5:1a:01:11"
  region = "us-phoenix-1"
}


# provider "kubernetes" {
#   # overwrite config_path to ensure existing kubeconfig does not get used
#   config_path = ""

#   # build kube config based on output of platform module to ensure that it
#   # speaks to the new cluster when creating the aws-auth configmap
#   host                   = module.platform.eks_cluster_endpoint
#   cluster_ca_certificate = base64decode(module.platform.eks_cluster_certificate_authority_data)

#   exec {
#     api_version = "client.authentication.k8s.io/v1beta1"
#     command     = "aws"
#     args        = local.kubernetes_provider_command_args
#   }
# }
