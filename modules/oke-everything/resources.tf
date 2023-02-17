
module "network" {
  source = "../oke-network"

  compartment_ocid = var.compartment_ocid
}

module "cluster" {
  source = "../oke-cluster"

  compartment_ocid   = var.compartment_ocid
  kubernetes_version = var.kubernetes_version

  global_freeform_tags    = var.global_freeform_tags
  vcn_id                  = module.network.vcn_id
  nsg_id                  = module.network.network_security_group_id
  public_subnet_id        = module.network.public_regional_subnet_id
  loadbalancer_subnet_ids = [module.network.public_subnet_a_id, module.network.public_subnet_b_id]
  service_subnet_cidr     = "10.21.0.0/16"

  #regional_subnet_a_id  = module.network.private_subnet_ids[0]
  #nodepool_a_subnet_ids = [module.network.private_subnet_ids[0]]
  #regional_subnet_b_id  = module.network.private_subnet_ids[1]
  #nodepool_b_subnet_ids = [module.network.private_subnet_ids[1]]
  #public_subnet_a_id    = module.network.public_subnet_a
  nodepool_a_subnet_ids = [module.network.private_subnet_a_id]
  #public_subnet_b_id    = module.network.public_subnet_b
  nodepool_b_subnet_ids = [module.network.private_subnet_b_id]
}

data "oci_objectstorage_namespace" "bucket_namespace" {
  compartment_id = var.compartment_ocid
}

resource "oci_objectstorage_bucket" "platform_metrics_bucket" {
  compartment_id = var.compartment_ocid
  name           = "${var.infra_set_name}_catalyst_metrics_bucket"
  namespace      = data.oci_objectstorage_namespace.bucket_namespace.namespace
}

resource "oci_identity_user" "platform_metrics_bucket_user" {
  compartment_id = var.compartment_ocid
  name           = "${var.infra_set_name}_catalyst_metrics_bucket_user"
  email          = "tod+${var.infra_set_name}@phonejanitor.com"
  description    = "User to access the ${var.infra_set_name}_catalyst_metrics_bucket_user"
  freeform_tags  = merge(var.global_freeform_tags, {})
}

resource "oci_identity_group" "platform_metrics_users" {
  compartment_id = var.compartment_ocid
  description    = "Group for managing access to ${var.infra_set_name}_catalyst_metrics_bucket"
  name           = "${var.infra_set_name}_metrics_users"

  freeform_tags = merge(var.global_freeform_tags, {})
}

resource "oci_identity_policy" "platform_metrics_bucket_user_policy" {
  compartment_id = var.compartment_ocid
  description    = "Allow the metrics bucket user have access to the metrics bucket of th ${var.infra_set_name} stack."
  name           = "${var.infra_set_name}_catalyst_metrics_bucket_user_policy"
  statements = [
    "Allow group ${var.infra_set_name}_metrics_users to manage buckets in tenancy where all {target.bucket.name='${var.infra_set_name}_catalyst_metrics_bucket'}",
    "Allow group ${var.infra_set_name}_metrics_users to manage objects in tenancy where all {target.bucket.name='${var.infra_set_name}_catalyst_metrics_bucket'}",
  ]

  freeform_tags = merge(var.global_freeform_tags, {})
}

resource "oci_identity_user_group_membership" "platform_metrics_bucket_users_group_membership" {
  group_id = oci_identity_group.platform_metrics_users.id
  user_id  = oci_identity_user.platform_metrics_bucket_user.id
}

resource "oci_identity_customer_secret_key" "platform_metrics_bucket_user_key" {
  display_name = "Keys for the ${var.infra_set_name}_catalyst_metrics_bucket_user"
  user_id      = oci_identity_user.platform_metrics_bucket_user.id
}

# This ensures we only have encrypted block volumes ever on this cluster
resource "null_resource" "delete_storageclasses" {
  provisioner "local-exec" {
    command     = "kubectl delete storageclass --all"
    interpreter = ["/bin/bash", "-c"]
  }
  depends_on = [module.cluster]
}

resource "kubernetes_storage_class" "platform_storage_class_paravirtualized" {
  depends_on = [null_resource.delete_storageclasses]
  metadata {
    name = "oci-bv-enc"
    annotations = {
      "storageclass.kubernetes.io/is-default-class" = "true"
    }
  }
  storage_provisioner = "blockvolume.csi.oraclecloud.com"
  reclaim_policy      = "Retain"
  parameters = {
    attachment-type = "paravirtualized"
  }
  allow_volume_expansion = true
  volume_binding_mode    = "WaitForFirstConsumer"
}

resource "kubernetes_namespace" "metrics_bucket_namespaces" {
  for_each   = toset(var.metrics_bucket_namespaces)
  depends_on = [module.cluster]

  metadata {
    name = each.key
  }
}

resource "kubernetes_secret_v1" "metrics_bucket_namespace_secrets" {
  for_each   = toset(var.metrics_bucket_namespaces)
  depends_on = [kubernetes_namespace.metrics_bucket_namespaces]

  metadata {
    name      = "metricsbucketaccess"
    namespace = each.key
  }

  data = {
    #AWS_ACCESS_KEY_ID
    access_key_id = oci_identity_customer_secret_key.platform_metrics_bucket_user_key.id
    #AWS_SECRET_ACCESS_KEY 
    secret_access_key = oci_identity_customer_secret_key.platform_metrics_bucket_user_key.key
  }
}

# If successful, this should be ready for the module at:
# catalystsquad/catalyst-cluster-bootstrap/kubernetes
