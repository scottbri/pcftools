#!/bin/bash


if [ $# -lt 1 ] ; then
        echo "Usage: $0 PCF_DOMAIN_NAME"
        echo ""
        echo "where:"
        echo "     PCF_DOMAIN_NAME:   domain name of your PCF deployment including the environment name"
        echo "         As in: pcf.example.com"
        echo ""
        exit 1
fi

PCF_DOMAIN_NAME=$1

cat > ./${PCF_DOMAIN_NAME}.cnf <<-EOF
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
O=PIVOTAL, INC.
OU=Workshops
CN = ${PCF_DOMAIN_NAME}

[ req_ext ]
subjectAltName = @alt_names

[ alt_names ]
DNS.1 = *.sys.${PCF_DOMAIN_NAME}
DNS.2 = *.login.sys.${PCF_DOMAIN_NAME}
DNS.3 = *.uaa.sys.${PCF_DOMAIN_NAME}
DNS.4 = *.apps.${PCF_DOMAIN_NAME}
DNS.5 = *.pks.${PCF_DOMAIN_NAME}
EOF

openssl req -x509 \
  -newkey rsa:2048 \
  -nodes \
  -keyout ${PCF_DOMAIN_NAME}.key \
  -out ${PCF_DOMAIN_NAME}.cert \
  -config ${PCF_DOMAIN_NAME}.cnf

