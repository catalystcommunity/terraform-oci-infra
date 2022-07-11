terraform {
  backend "s3" {
    bucket         = "catalystsquadoci_tf_backend"
    key            = "terraform-oci-platform/nonprod"
    region         = "us-phoenix-1"
    endpoint = "https://axio5bp9omoq.compat.objectstorage.us-phoenix-1.oraclecloud.com"
    shared_credentials_file = "/home/todhansmann/.oci/aws_creds"
    skip_region_validation      = true
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    force_path_style            = true
  }
}
