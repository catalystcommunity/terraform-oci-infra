data "oci_identity_availability_domains" "ads" {
  compartment_id = local.compartment_ocid
}

data "oci_containerengine_node_pool_option" "node_pool_option" {
  # node_pool_option_id = oci_containerengine_cluster.platform_cluster.id
  node_pool_option_id = "all"
}

locals {
  compartment_id = "ocid1.tenancy.oc1..aaaaaaaafnc4ezkn7qo5neppywgy6hxgxyi7fgsjxo5n5e2wgxh7hviwh26a" 

  kubernetes_version = "1.24.1"
  node_pool_image_ids = data.oci_containerengine_node_pool_option.node_pool_option.sources
  oke_images = {
    for source in local.node_pool_image_ids : 
    source.source_name => source if length(regexall("^(Oracle-Linux-8.\\d*-\\d{4}.*-OKE-${local.kubernetes_version}.*)$", source.source_name)) > 0
  }
  oke_image_names = reverse(sort([for source in local.node_pool_image_ids : source.source_name if length(regexall("^(Oracle-Linux-8.\\d*-\\d{4}.*-OKE-${local.kubernetes_version}.*)$", source.source_name)) > 0]))
  latest_oke = local.oke_images[local.oke_image_names[0]]
}

module "network" {
  source   = "../modules/oke-network"

  compartment_id = local.compartment_id
}

module "cluster" {
  source   = "../modules/oke-cluster"

  compartment_id = local.compartment_id
  kubernetes_version = "1.24.1"

  global_freeform_tags = {
    "env" = "everything",
    "creator" = "Tod Hansmann",
    "creator_email" = "tod@phonejanitor.com",
  }

  vcn_id = module.network.vcn_id
  nsg_id = module.network.network_security_group_id
  public_subnet_id = module.network.subnet_ids[0]
  loadbalancer_subnet_ids = [module.network.subnet_ids[0]]
  regional_subnet_a_id = module.network.subnet_ids[2]
  nodepool_a_subnet_ids = [module.network.subnet_ids[2]]
  regional_subnet_b_id = module.network.subnet_ids[3]
  nodepool_b_subnet_ids = [module.network.subnet_ids[3]]
}

