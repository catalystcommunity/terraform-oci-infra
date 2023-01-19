# terraform-aws-platform

This repo contains a terraform implementation of all AWS cloud resources
required for operating Kubernetes.


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
