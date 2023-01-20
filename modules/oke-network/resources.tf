data "oci_identity_availability_domains" "ads" {
  compartment_id = var.compartment_id
}

resource "oci_core_vcn" "platform_vcn" {
  #Required
  compartment_id = var.compartment_id

  cidr_blocks   = var.vcn_cidr_blocks
  display_name  = "${var.infra_set_name}_vcn"
  dns_label     = "${var.infra_set_name}vcn"
  freeform_tags = merge(var.global_freeform_tags, {})
}

resource "oci_core_security_list" "platform_sl" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.platform_vcn.id

  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "all"
  }

  ingress_security_rules {
    protocol = "all"
    source   = "0.0.0.0/0"
  }

  display_name = "${var.infra_set_name}_sl"
}

resource "oci_core_subnet" "platform_subnets" {
  for_each          = { for idx, cidr_block in var.vcn_cidr_blocks : cidr_block => idx }
  cidr_block        = each.key
  compartment_id    = var.compartment_id
  vcn_id            = oci_core_vcn.platform_vcn.id
  security_list_ids = ["${oci_core_security_list.platform_sl.id}"]
  # Leave out the availability domain to make it a regional subnet_id
  # Of course, this doesn't WORK at all
  #availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  display_name   = format("${var.infra_set_name}_subnet_%d", each.value + 1)
  freeform_tags  = merge(var.global_freeform_tags, {})
  route_table_id = oci_core_route_table.platform_rt.id
}

resource "oci_core_internet_gateway" "platform_internet_gateway" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.platform_vcn.id
  display_name   = "${var.infra_set_name}_ig"
  enabled        = true
  freeform_tags  = merge(var.global_freeform_tags, {})
}

resource "oci_core_route_table" "platform_rt" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.platform_vcn.id

  route_rules {
    destination       = "0.0.0.0/0"
    network_entity_id = oci_core_internet_gateway.platform_internet_gateway.id
  }

  display_name = "${var.infra_set_name}-rt"
}

resource "oci_core_nat_gateway" "platform_nat_gateway" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.platform_vcn.id

  route_table_id = oci_core_route_table.platform_rt.id
  display_name   = "${var.infra_set_name}_nat_gateway"
  freeform_tags  = merge(var.global_freeform_tags, {})
}

#resource "oci_core_service_gateway" "platform_service_gateway" {
#  compartment_id = var.compartment_id
#  vcn_id         = oci_core_vcn.platform_vcn.id
#
#  route_table_id = oci_core_route_table.platform_rt.id
#  display_name   = "${var.infra_set_name}_service_gateway"
#  freeform_tags  = merge(var.global_freeform_tags, {})
#}

resource "oci_core_network_security_group" "platform_nsg" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.platform_vcn.id
  display_name   = "${var.infra_set_name}_nsg"
}



