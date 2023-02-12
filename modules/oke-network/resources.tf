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
  lifecycle {
    ignore_changes = all
  }
}

resource "oci_core_network_security_group" "platform_nsg" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.platform_vcn.id
  display_name   = "${var.infra_set_name}_nsg"
}

data "oci_core_services" "all_oci_services" {
  filter {
    name   = "name"
    values = ["All .* Services In Oracle Services Network"]
    regex  = true
  }
  count = 1
}

resource "oci_core_subnet" "platform_public_subnet_a" {
  cidr_block          = var.public_cidr_blocks[0]
  compartment_id      = var.compartment_id
  vcn_id              = oci_core_vcn.platform_vcn.id
  security_list_ids   = ["${oci_core_security_list.platform_sl.id}"]
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  display_name        = "${var.infra_set_name}_public_subnet_a"
  freeform_tags       = merge(var.global_freeform_tags, {})
  route_table_id      = oci_core_route_table.platform_rt.id
}

resource "oci_core_subnet" "platform_public_subnet_b" {
  cidr_block          = var.public_cidr_blocks[1]
  compartment_id      = var.compartment_id
  vcn_id              = oci_core_vcn.platform_vcn.id
  security_list_ids   = ["${oci_core_security_list.platform_sl.id}"]
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[1].name
  display_name        = "${var.infra_set_name}_public_subnet_b"
  freeform_tags       = merge(var.global_freeform_tags, {})
  route_table_id      = oci_core_route_table.platform_rt.id
}

resource "oci_core_subnet" "platform_public_regional_subnet" {
  cidr_block        = var.vcn_cidr_blocks[4]
  compartment_id    = var.compartment_id
  vcn_id            = oci_core_vcn.platform_vcn.id
  security_list_ids = ["${oci_core_security_list.platform_sl.id}"]
  #Make regional subnet
  #availability_domain = data.oci_identity_availability_domains.ads.availability_domains[1].name
  display_name   = "${var.infra_set_name}_public_regional_subnet"
  freeform_tags  = merge(var.global_freeform_tags, {})
  route_table_id = oci_core_route_table.platform_rt.id
}

resource "oci_core_subnet" "platform_private_subnet_a" {
  cidr_block                 = var.private_cidr_blocks[0]
  compartment_id             = var.compartment_id
  vcn_id                     = oci_core_vcn.platform_vcn.id
  security_list_ids          = ["${oci_core_security_list.platform_sl.id}"]
  availability_domain        = data.oci_identity_availability_domains.ads.availability_domains[0].name
  prohibit_public_ip_on_vnic = true
  display_name               = "${var.infra_set_name}_private_subnet_a"
  freeform_tags              = merge(var.global_freeform_tags, {})
  route_table_id             = oci_core_route_table.platform_nat_rt.id
}

resource "oci_core_subnet" "platform_private_subnet_b" {
  cidr_block                 = var.private_cidr_blocks[1]
  compartment_id             = var.compartment_id
  vcn_id                     = oci_core_vcn.platform_vcn.id
  security_list_ids          = ["${oci_core_security_list.platform_sl.id}"]
  availability_domain        = data.oci_identity_availability_domains.ads.availability_domains[1].name
  prohibit_public_ip_on_vnic = true
  display_name               = "${var.infra_set_name}_private_subnet_b"
  freeform_tags              = merge(var.global_freeform_tags, {})
  route_table_id             = oci_core_route_table.platform_nat_rt.id
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
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.platform_internet_gateway.id
  }

  display_name = "${var.infra_set_name}-ig-rt"
}

resource "oci_core_route_table" "platform_nat_rt" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.platform_vcn.id

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_nat_gateway.platform_nat_gateway.id
  }

  display_name = "${var.infra_set_name}-nat-rt"
}

resource "oci_core_nat_gateway" "platform_nat_gateway" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.platform_vcn.id

  #route_table_id = oci_core_route_table.platform_nat_rt.id
  display_name  = "${var.infra_set_name}_nat_gateway"
  freeform_tags = merge(var.global_freeform_tags, {})
}


