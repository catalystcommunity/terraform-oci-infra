output "all-availability-domains-in-tenancy" {
  value = data.oci_identity_availability_domains.ads.availability_domains
}

output "name-of-first-availability-domain" {
  value = data.oci_identity_availability_domains.ads.availability_domains[0].name
}

output "cluster_id" {
  value = oci_containerengine_cluster.platform_cluster.id
}

output "cluster_pub_endpoint" {
  value = oci_containerengine_cluster.platform_cluster.endpoints[0].public_endpoint
}

output "oke_image_id" {
  value = local.latest_oke.image_id
}
