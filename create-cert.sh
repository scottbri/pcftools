#!/bin/bash


if [ $# -lt 1 ] ; then
        echo "Usage: $0 DOMAIN_NAME"
        echo ""
        echo "where:"
        echo "     DOMAIN_NAME:	domain name of your tanzu deployment including the subdomain name"
        echo "			As in: project.example.com"
        echo "		A wildcard Alt Name will be created at the domain name specified"
        echo "			As in: *.project.example.com"
        echo "		Additional wildcard subdomains may be specified by editing the script"
        echo '			As in: *.apps.${DOMAIN_NAME}'
        echo ""
        exit 1
fi

DOMAIN_NAME=$1

cat > ./${DOMAIN_NAME}.config <<-EOF
[req]
default_bits = 2048
prompt = no
default_md = sha256
req_extensions = req_ext
distinguished_name = dn

[ dn ]
C=US
ST=California
L=San Francisco
O=My Company
OU=Lab
CN = ${DOMAIN_NAME}

[ req_ext ]
subjectAltName = @alt_names

[ alt_names ]
DNS.1 = *.${DOMAIN_NAME}
DNS.2 = *.apps.${DOMAIN_NAME}
DNS.3 = *.dev.${DOMAIN_NAME}
DNS.4 = *.test.${DOMAIN_NAME}
DNS.5 = *.stage.${DOMAIN_NAME}
EOF

openssl req -x509 \
  -newkey rsa:2048 \
  -nodes \
  -keyout ${DOMAIN_NAME}.key \
  -out ${DOMAIN_NAME}.cert \
  -config ${DOMAIN_NAME}.config
