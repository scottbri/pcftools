#!/bin/bash

OMFQDN=$1
USERNAME=$2
PASSWORD=$3
FILENAME=$4

om -t $OMFQDN -u $USERNAME -p $PASSWORD -k available-products

echo ""
echo "From the above output, what Product Name do you want to stage:"
read PRODUCTNAME
echo ""
echo "From the above output, what is the Version of the Product you want to stage:"
read VERSION

om -t $OMFQDN -u $USERNAME -p $PASSWORD -k stage-product --product-name $PRODUCTNAME --product-version $VERSION
