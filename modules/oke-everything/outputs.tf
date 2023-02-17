output "cluster_id" {
  value = module.cluster.cluster_id
}

output "cluster_pub_endpoint" {
  value = module.cluster.cluster_pub_endpoint
}

output "oke_image_id" {
  value = module.cluster.oke_image_id
}

output "metrics_bucket_user_key_id" {
  value     = oci_identity_customer_secret_key.platform_metrics_bucket_user_key.id
  sensitive = true
}

output "metrics_bucket_user_access_key" {
  value     = oci_identity_customer_secret_key.platform_metrics_bucket_user_key.key
  sensitive = true
}

