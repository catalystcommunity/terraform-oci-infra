variable "compartment_ocid" {
  type        = string
  nullable    = false
  description = "The compartment this infrastructure will be part of, can be a tenant ocid for root compartment"
}

variable "kubernetes_version" {
  type        = string
  default     = "1.25.4"
  description = "The semver of the kubernetes version to use, check OCI availability for valid versions. We add the v in the front where needed."
}

variable "infra_set_name" {
  type        = string
  default     = "catalystoci"
  description = "The name we apply to resources. Can be ignored for single-cluster setups."
}

variable "infra_email" {
  type        = string
  description = "The email for infra users such as the metrics bucket user"
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
  default     = 2
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

variable "metrics_bucket_namespaces" {
  type = list(string)
  default = [
    "cortex",
    "loki",
  ]
  description = "Kubernetes namespaces that need the metrics bucket access creds secret."
}

# manage secrets for this environment via oci secrets manager for secret

# Tags! Will be merged with other tags and shoved in freeform tags
variable "global_freeform_tags" {
  type = map(string)
  default = {
    "infra_from" = "Catalyst Platform"
  }
  description = "Tags that get applied to all resources created in the module"
}

