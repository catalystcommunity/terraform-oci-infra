output "cluster_id" {
  value = oci_containerengine_cluster.platform_cluster.id
}

output "cluster_pub_endpoint" {
  value = oci_containerengine_cluster.platform_cluster.endpoints[0].public_endpoint
}

output "oke_image_id" {
  value = local.latest_oke.image_id
}
