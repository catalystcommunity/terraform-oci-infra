# terraform-oci-platform

This repo contains a terraform implementation of all Oracle Cloud resources required for a barebones Kubernetes cluster ready for the Catalyst Platform Services


# For Linkerd CA creation

If you don't have your own PEM and such, this bash will generate everything you need for the PEM

```bash
openssl ecparam -name prime256v1 -genkey -noout -out ca-private.pem
openssl ec -in ca-private.pem -pubout -out ca-public.pem
openssl req -x509 -new -key ca-private.pem -days 365 -out ca.crt -subj "/CN=root.linkerd.cluster.local"
openssl ecparam -name prime256v1 -genkey -noout -out issuer-private.pem
openssl ec -in issuer-private.pem -pubout -out issuer-public.pem
openssl req -new -key issuer-private.pem -out issuer.csr -subj "/CN=identity.linkerd.cluster.local" \
    -addext basicConstraints=critical,CA:TRUE
openssl x509 \
    -extfile /etc/ssl/openssl.cnf \
    -extensions v3_ca \
    -req \
    -in issuer.csr \
    -days 180 \
    -CA ca.crt \
    -CAkey ca-private.pem \
    -CAcreateserial \
    -extensions v3_ca \
    -out issuer.crt
rm issuer.csr
```

# Caveats

You will need to separately deploy the bootstrap module at:
`catalystcommunity/catalyst-cluster-bootstrap/kubernetes`

This will require a secrets to be created manually and then used something like the following

```terraform
 # manage secrets for this environment via oci secrets manager for secret
 # versioning and oci access control over secrets
 data "oci_secrets_secretbundle" "platform_secrets" {
   secret_id = var.platform_secret_ocid
 }

 locals {                                                                                                                 12   environment_name = "everything"                                                                                        11   secrets = sensitive(                                                                                                   10     jsondecode(                                                                                                           9       base64decode(                                                                                                       8         data.oci_secrets_secretbundle.platform_secrets.secret_bundle_content.0.content                                    7       )
     )
   )
 }
```

