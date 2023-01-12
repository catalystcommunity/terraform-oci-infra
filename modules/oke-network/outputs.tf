output "vcn_id" {
  value = oci_core_vcn.platform_vcn.id
}

output "compartment_id" {
  value = var.compartment_id
}

output "security_list_id" {
  value = oci_core_security_list.platform_sl.id
}

output "subnet_names" {
  value = [
    for subnet in oci_core_subnet.platform_subnets: subnet.display_name
  ]
}

output "subnet_ids" {
  value = [
    for subnet in oci_core_subnet.platform_subnets: subnet.id
  ]
}

output "subnet_dns_labels" {
  value = [
    for subnet in oci_core_subnet.platform_subnets: subnet.dns_label
  ]
}

output "internet_gateway_id" {
  value = oci_core_internet_gateway.platform_internet_gateway.id
}

output "route_table_id" {
  value = oci_core_route_table.platform_rt.id
}

output "network_security_group_id" {
  value = oci_core_network_security_group.platform_nsg.id
}

