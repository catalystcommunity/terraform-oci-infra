output "vcn_id" {
  value = oci_core_vcn.platform_vcn.id
}

output "compartment_id" {
  value = var.compartment_id
}

output "security_list_id" {
  value = oci_core_security_list.platform_sl.id
}

output "public_subnet_a_id" {
  value = oci_core_subnet.platform_public_subnet_a.id
}

output "public_subnet_b_id" {
  value = oci_core_subnet.platform_public_subnet_b.id
}

output "public_regional_subnet_id" {
  value = oci_core_subnet.platform_public_regional_subnet.id
}

output "private_subnet_a_id" {
  value = oci_core_subnet.platform_private_subnet_a.id
}

output "private_subnet_b_id" {
  value = oci_core_subnet.platform_private_subnet_b.id
}

output "internet_gateway_id" {
  value = oci_core_internet_gateway.platform_internet_gateway.id
}

output "route_table_id" {
  value = oci_core_route_table.platform_rt.id
}

output "route_table_nat_id" {
  value = oci_core_route_table.platform_nat_rt.id
}

output "network_security_group_id" {
  value = oci_core_network_security_group.platform_nsg.id
}

