#!/bin/bash

OMFQDN=$1
USERNAME=$2
PASSWORD=$3
FILENAME=$4

om -t $OMFQDN -u $USERNAME -p $PASSWORD -k upload-product -p $FILENAME
om -t $OMFQDN -u $USERNAME -p $PASSWORD -k available-products

om -t pcf.lab1.gcp.harnessingunicorns.io -u lab1admin -p lab1admin -k available-products
om -t pcf.lab1.gcp.harnessingunicorns.io -u lab1admin -p lab1admin -k stage-product --product-name pivotal-container-service --product-version 1.0.3-build.15
