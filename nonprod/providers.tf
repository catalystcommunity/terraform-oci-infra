terraform {
  required_version = ">= 1.2.0"

  required_providers {
    oci = {
      source  = "oracle/oci"
      version = "~> 4.0"
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

  compartment_ocid = "ocid1.tenancy.oc1..aaaaaaaa23mqlgnngz7nefy2jpbmwfnzrvtzqthpqmh4u3ssim5up547uchq"
  user_ocid = "ocid1.user.oc1..aaaaaaaatefv4vvgdagearf2ewkzz3pvm64gs3qhtecaxaqbdi6zin42zzca" 

  global_tags = {
    "env" = "nonprod"
  }
}

provider "oci" {
  tenancy_ocid = local.compartment_ocid
  user_ocid = local.user_ocid
  private_key_path = "/home/todhansmann/.oci/root.pem"
  fingerprint = "8d:d6:ad:26:08:b4:9e:e7:75:37:3a:c3:93:88:8b:8d"
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
