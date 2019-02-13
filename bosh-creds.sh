#!/bin/bash


if [ $# -lt 2 ] ; then
        echo "Usage: $0 OPSMAN_FQDN OPSMAN_ADMIN_USER OPSMAN_ADMIN_PASSWORD"
        echo ""
        echo "where:"
        echo "     OPSMAN_FQDN:           the Ops Manager domain name or IP"
        echo "     OPSMAN_ADMIN_USER:     the Ops Manager admin user name"
        echo "     OPSMAN_ADMIN_PASSWORD: the Ops Manager admin password"
        echo ""
        exit 1
fi

PCF_OPSMAN_FQDN="$1"
PCF_OPSMAN_ADMIN_PASSWD="$2"
PCF_OPSMAN_ADMIN_PASSWD="$3"

BOSH_CREDS=$( \
  om \
    --skip-ssl-validation \
    --target ${PCF_OPSMAN_FQDN} \
    --username admin \
    --password ${PCF_OPSMAN_ADMIN_PASSWD} \
    curl \
      --silent \
      --path /api/v0/deployed/director/credentials/bosh_commandline_credentials | \
        jq --raw-output '.credential' \
)

for BOSH_CRED in ${BOSH_CREDS}
do
  case ${BOSH_CRED} in
    @(BOSH_CLIENT*|BOSH_CLIENT_SECRET*|BOSH_ENVIRONMENT*|BOSH_CA_CERT*) )
      echo "export ${BOSH_CRED}" >> ./.envrc
      ;;
  esac
done

sudo mkdir -p /var/tempest/workspaces/default

sudo sh -c \
  "om \
    --skip-ssl-validation \
    --target ${PCF_OPSMAN_FQDN} \
    --username admin \
    --password ${PCF_OPSMAN_ADMIN_PASSWD} \
    curl \
      --silent \
      --path "/api/v0/security/root_ca_certificate" |
        jq --raw-output '.root_ca_certificate_pem' \
          > /var/tempest/workspaces/default/root_ca_certificate"

echo "execute 'source ./.envrc' to bring bosh environment variables into your shell"
