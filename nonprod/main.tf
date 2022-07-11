data "oci_identity_availability_domains" "ads" {
  compartment_id = local.compartment_ocid
}

data "oci_containerengine_node_pool_option" "node_pool_option" {
  # node_pool_option_id = oci_containerengine_cluster.platform_cluster.id
  node_pool_option_id = "all"
}

locals {
  kubernetes_version = "1.23.4"
  node_pool_image_ids = data.oci_containerengine_node_pool_option.node_pool_option.sources
  oke_images = {
    for source in local.node_pool_image_ids : 
    source.source_name => source if length(regexall("^(Oracle-Linux-8.\\d*-\\d{4}.*-OKE-${local.kubernetes_version}.*)$", source.source_name)) > 0
  }
  oke_image_names = reverse(sort([for source in local.node_pool_image_ids : source.source_name if length(regexall("^(Oracle-Linux-8.\\d*-\\d{4}.*-OKE-${local.kubernetes_version}.*)$", source.source_name)) > 0]))
  latest_oke = local.oke_images[local.oke_image_names[0]]
}

resource "oci_identity_compartment" "tf-compartment" {
    # Required
    compartment_id = local.compartment_ocid
    description = "Compartment for Nonprod TF resources."
    name = "nonprod"
}

resource "oci_core_vcn" "platform_vcn" {
    #Required
    compartment_id = local.compartment_ocid

    cidr_blocks = [
      "10.20.0.0/16"
    ]
    display_name = "nonprod_vcn"
    freeform_tags = merge(local.global_tags, {})
}

resource "oci_core_subnet" "platform_subnet" {
    cidr_block = "10.20.0.0/16"
    compartment_id = local.compartment_ocid
    vcn_id = oci_core_vcn.platform_vcn.id
    # Leave out the availability domain to make it a regional subnet
    # availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
    display_name = "nonprod_subnet_a"
    freeform_tags = merge(local.global_tags, {})
}

resource "oci_core_internet_gateway" "platform_internet_gateway" {
    compartment_id = local.compartment_ocid
    vcn_id = oci_core_vcn.platform_vcn.id
    display_name = "nonprod_ig"
    enabled = true
    freeform_tags = merge(local.global_tags, {})
}

resource "oci_containerengine_cluster" "platform_cluster" {
    compartment_id = local.compartment_ocid
    kubernetes_version = join("", ["v",local.kubernetes_version])
    name = "nonprod"
    vcn_id = oci_core_vcn.platform_vcn.id

    endpoint_config {
        is_public_ip_enabled = true
        subnet_id = oci_core_subnet.platform_subnet.id
    }
    freeform_tags = merge(local.global_tags, {})
    options {
        persistent_volume_config {
            freeform_tags = merge(local.global_tags, {})
        }
        service_lb_config {
            freeform_tags = merge(local.global_tags, {})
        }
    }
}

resource "oci_containerengine_node_pool" "platform_nodepool_a" {
    cluster_id = oci_containerengine_cluster.platform_cluster.id
    compartment_id = local.compartment_ocid
    name = "platform_nodepool_a"
    node_shape = "VM.Standard.E4.Flex"
    kubernetes_version = oci_containerengine_cluster.platform_cluster.kubernetes_version

    # freeform_tags = merge(local.global_tags, {})
    node_shape_config {
        memory_in_gbs = 16
        ocpus = 1
    }
    node_config_details {
        placement_configs {
            availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
            subnet_id = oci_core_subnet.platform_subnet.id
        }
        size = 1

        is_pv_encryption_in_transit_enabled = true
        freeform_tags =  merge(local.global_tags, {})
    }
    node_source_details {
        #Required
        # image_id = data.oci_core_images.oraclelinux-8-oke.images.0.id
        image_id = local.latest_oke.image_id
        source_type = "IMAGE"
        boot_volume_size_in_gbs = 50
    }
}

resource "oci_containerengine_node_pool" "platform_nodepool_b" {
    cluster_id = oci_containerengine_cluster.platform_cluster.id
    compartment_id = local.compartment_ocid
    name = "platform_nodepool_b"
    node_shape = "VM.Standard.E4.Flex"
    kubernetes_version = oci_containerengine_cluster.platform_cluster.kubernetes_version

    # freeform_tags = merge(local.global_tags, {})
    node_shape_config {
        memory_in_gbs = 16
        ocpus = 1
    }
    node_config_details {
        placement_configs {
            availability_domain = data.oci_identity_availability_domains.ads.availability_domains[1].name
            subnet_id = oci_core_subnet.platform_subnet.id
        }
        size = 1

        is_pv_encryption_in_transit_enabled = true
        freeform_tags =  merge(local.global_tags, {})
    }
    node_source_details {
        #Required
        # image_id = data.oci_core_images.oraclelinux-8-oke.images.0.id operating-system-version
        image_id = local.latest_oke.image_id
        source_type = "IMAGE"
        boot_volume_size_in_gbs = 50
    }
}