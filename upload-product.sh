#!/bin/bash

if [ $# -lt 4 ] ; then
	echo "Usage: $0 <FQDN> <username> <password> <filename>"
	echo ""
	echo "where:"
	echo "     FQDN:      the domain name or IP of Ops Manager"
	echo "     username:  the admin user for Ops Manager"
	echo "     password:  the password for the admin user"
	echo "     filename:  the file to upload to Ops Manager"
	echo ""
	exit 1
fi

OMFQDN=$1
USERNAME=$2
PASSWORD=$3
FILENAME=$4

om -t $OMFQDN -u $USERNAME -p $PASSWORD -k upload-product -p $FILENAME
om -t $OMFQDN -u $USERNAME -p $PASSWORD -k available-products
