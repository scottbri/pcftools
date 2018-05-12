#!/bin/bash

if [ $# -lt 3 ] ; then
	echo "Usage: $0 <FQDN> <username> <password>"
	echo ""
	echo "where:"
	echo "     FQDN:      the domain name or IP of Ops Manager"
	echo "     username:  the admin user for Ops Manager"
	echo "     password:  the password for the admin user"
	echo ""
	exit 1
fi

OMFQDN=$1
USERNAME=$2
PASSWORD=$3

om -t $OMFQDN -u $USERNAME -p $PASSWORD -k available-products

echo ""
echo "From the above output, what Product Name do you want to stage:"
read PRODUCTNAME
echo ""
echo "From the above output, what is the Version of the Product you want to stage:"
read VERSION

om -t $OMFQDN -u $USERNAME -p $PASSWORD -k stage-product --product-name $PRODUCTNAME --product-version $VERSION
