variable "compartment_id" {
  type        = string
  nullable    = false
  description = "The compartment this infrastructure will be part of, can be a tenant ocid for root compartment"
}

variable "vcn_cidr_blocks" {
  type        = list(string)
  default     = [
      "10.20.0.0/16",
      "10.21.0.0/16",
      "10.22.0.0/16",
      "10.23.0.0/16",
    ]
  description = "The network address space for this vcn. At least 4 are required. Ignore this unless you absolutely can not"
}

variable "infra_set_name" {
  type        = string
  default     = "catalystoci"
  description = "The name we apply to resources. Can be ignored for single-cluster setups."
}

# Tags! Will be merged with other tags and shoved in freeform tags
variable "global_freeform_tags" {
  type        = map(string)
  default     = {
    "infra_from" = "Catalyst Platform"
  }
  description = "Tags that get applied to all resources created in the module"
}


