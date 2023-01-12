data "oci_containerengine_node_pool_option" "node_pool_option" {
  # node_pool_option_id = oci_containerengine_cluster.platform_cluster.id
  node_pool_option_id = "all"
}

data "oci_identity_availability_domains" "ads" {
  compartment_id = var.compartment_id
}

locals {
  node_pool_image_ids = data.oci_containerengine_node_pool_option.node_pool_option.sources
  oke_images = {
    for source in local.node_pool_image_ids : 
    source.source_name => source if length(regexall("^(Oracle-Linux-8.\\d*-\\d{4}.*-OKE-${var.kubernetes_version}.*)$", source.source_name)) > 0
  }
  oke_image_names = reverse(sort([for source in local.node_pool_image_ids : source.source_name if length(regexall("^(Oracle-Linux-8.\\d*-\\d{4}.*-OKE-${var.kubernetes_version}.*)$", source.source_name)) > 0]))
  latest_oke = local.oke_images[local.oke_image_names[0]]
}

resource "oci_containerengine_cluster" "platform_cluster" {
    compartment_id = "${var.compartment_id}"
    kubernetes_version = join("", ["v",var.kubernetes_version])
    name = "${var.infra_set_name}_oke"
    vcn_id = "${var.vcn_id}"

    endpoint_config {
        is_public_ip_enabled = true
        subnet_id = "${var.public_subnet_id}"
    }
    freeform_tags = merge(var.global_freeform_tags, {})
    cluster_pod_network_options {
        cni_type = "OCI_VCN_IP_NATIVE"
    }
    options {
        persistent_volume_config {
            freeform_tags = merge(var.global_freeform_tags, {})
        }
        service_lb_config {
            freeform_tags = merge(var.global_freeform_tags, {})
        }
        service_lb_subnet_ids = var.loadbalancer_subnet_ids
    }
}

resource "oci_containerengine_node_pool" "platform_nodepool_a" {
    cluster_id = oci_containerengine_cluster.platform_cluster.id
    compartment_id = var.compartment_id
    name = "${var.infra_set_name}_nodepool_a"
    node_shape = var.node_shape
    kubernetes_version = oci_containerengine_cluster.platform_cluster.kubernetes_version

    # freeform_tags = merge(local.global_tags, {})
    node_shape_config {
        memory_in_gbs = var.node_memory_gbs
        ocpus = var.node_ocpus
    }
    node_config_details {
        placement_configs {
            availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
            subnet_id = "${var.regional_subnet_a_id}"
        }
        size = 1

        is_pv_encryption_in_transit_enabled = true
        freeform_tags =  merge(var.global_freeform_tags, {})
        node_pool_pod_network_option_details {
            cni_type          = "OCI_VCN_IP_NATIVE"
            max_pods_per_node = var.node_max_pods
            pod_nsg_ids       = ["${var.nsg_id}"]
            pod_subnet_ids    = var.nodepool_a_subnet_ids
        }
    }
    node_source_details {
        #Required
        # image_id = data.oci_core_images.oraclelinux-8-oke.images.0.id
        image_id = local.latest_oke.image_id
        source_type = "IMAGE"
        boot_volume_size_in_gbs = var.boot_volume_gbs
    }
}

resource "oci_containerengine_node_pool" "platform_nodepool_b" {
    cluster_id = oci_containerengine_cluster.platform_cluster.id
    compartment_id = var.compartment_id
    name = "${var.infra_set_name}_nodepool_b"
    node_shape = var.node_shape
    kubernetes_version = oci_containerengine_cluster.platform_cluster.kubernetes_version

    # freeform_tags = merge(local.global_tags, {})
    node_shape_config {
        memory_in_gbs = var.node_memory_gbs
        ocpus = var.node_ocpus
    }
    node_config_details {
        placement_configs {
            availability_domain = data.oci_identity_availability_domains.ads.availability_domains[1].name
            subnet_id = "${var.regional_subnet_b_id}"
        }
        size = 1

        is_pv_encryption_in_transit_enabled = true
        freeform_tags =  merge(var.global_freeform_tags, {})
        node_pool_pod_network_option_details {
            cni_type          = "OCI_VCN_IP_NATIVE"
            max_pods_per_node = var.node_max_pods
            pod_nsg_ids       = ["${var.nsg_id}"]
            pod_subnet_ids    = var.nodepool_b_subnet_ids
        }
    }
    node_source_details {
        #Required
        # image_id = data.oci_core_images.oraclelinux-8-oke.images.0.id operating-system-version
        image_id = local.latest_oke.image_id
        source_type = "IMAGE"
        boot_volume_size_in_gbs = var.boot_volume_gbs
    }
}


