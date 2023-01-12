variable "compartment_id" {
  type        = string
  nullable    = false
  description = "The compartment this infrastructure will be part of, can be a tenant ocid for root compartment"
}

variable "kubernetes_version" {
  type        = string
  default     = "1.24.1"
  description = "The semver of the kubernetes version to use, check OCI availability for valid versions. We add the v in the front where needed."
}

variable "infra_set_name" {
  type        = string
  default     = "catalystoci"
  description = "The name we apply to resources. Can be ignored for single-cluster setups."
}

# Node VM attributes, uniform because this is a simple example. If you need customization, just copy this module and 
# start augmenting, but then why are you using OCI? You're ready for a better cloud.
variable "node_shape" {
  type        = string
  default     = "VM.Standard.E4.Flex"
  description = "OCI Shape for Nodes"
}

variable "node_memory_gbs" {
  type        = number
  default     = 16
  description = "The number of RAM GBs per node."
}

variable "node_ocpus" {
  type        = number
  default     = 1
  description = "The number of ocpus per node."
}

variable "node_max_pods" {
  type        = number
  default     = 30
  description = "The number of pods allowed per node. Max can be per shape and we don't know where this is published."
}

variable "boot_volume_gbs" {
  type        = number
  default     = 50
  description = "The size of the boot volume for nodes. Not a PV, just the node's spill-over."
}



# Tags! Will be merged with other tags and shoved in freeform tags
variable "global_freeform_tags" {
  type        = map(string)
  default     = {
    "infra_from" = "Catalyst Platform"
  }
  description = "Tags that get applied to all resources created in the module"
}


# Network stuff, be wary here.
variable "vcn_id" {
  type        = string
  nullable    = false
  description = "The id of the vcn to put this in."
}

variable "nsg_id" {
  type        = string
  nullable    = false
  description = "The id of the nsg for the cluster and nodepools."
}

variable "public_subnet_id" {
  type        = string
  nullable    = false
  description = "The subnet id for public endpoints. This Must be a public subnet, or things will be broken in odd ways."
}

variable "loadbalancer_subnet_ids" {
  type        = list(string)
  nullable    = false
  description = "A list of one or more subnet ids to put load balancers in. This must be public, and different from the nodepool subnet list members."
}

variable "regional_subnet_a_id" {
  type        = string
  nullable    = false
  description = "The subnet id for nodepool b placement config. This is seemingly ignored, but needed. More testing necessary."
}

variable "nodepool_a_subnet_ids" {
  type        = list(string)
  nullable    = false
  description = "A list of subnet ids for pods to be placed in for nodepool b. All should be regional. It can be a list of one, but all items must be different than load_balancer_subnet_ids"
}

variable "regional_subnet_b_id" {
  type        = string
  nullable    = false
  description = "The subnet id for nodepool b placement config. This is seemingly ignored, but needed. More testing necessary."
}

variable "nodepool_b_subnet_ids" {
  type        = list(string)
  nullable    = false
  description = "A list of subnet ids for pods to be placed in for nodepool b. All should be regional. It can be a list of one, but all items must be different than load_balancer_subnet_ids"
}


