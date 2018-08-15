#!/bin/bash

if [ $# -lt 5 ] ; then
	echo "Usage: $0 <FQDN> {admin|manage} <username> <email> <password>"
	echo ""
	echo "where:"
	echo "     FQDN:      the domain name or IP of PKS API server"
	echo "     admin or manage  admin is able to manage any K8s cluster, manage only able to manage own"
	echo "     username:  the user name to be created for PKS API access"
	echo "     email:     the user's email address"
	echo "     password:  the password for the new user"
	echo ""
	echo "Note: the script will prompt for the PKS UAA Management Admin Client Credential from PKS Tile"
	exit 1
fi

PKS_API_FQDN=$1
ROLE=$2
USERNAME=$3
EMAIL=$4
PASSWORD=$5

echo "Targeting $PKS_API_FQDN"
uaac target $PKS_API_FQDN:8443 --skip-ssl-validation

echo ""
echo "Please provide the PKS UAA Managemetn Admin Client Credential from the PKS Tile:"
read $PKS_CREDENTIAL
echo "Getting the administrative access token"
uaac token client get admin -s $PKS_CREDENTIAL

echo "Adding user $USERNAME to uaa"
uaac user add $USERNAME --emails $EMAIL -p $PASSWORD

echo "Assigning the user $USERNAME to the pks.clusters.$ROLE role"
uaac member add pks.clusters.$ROLE $USERNAME

