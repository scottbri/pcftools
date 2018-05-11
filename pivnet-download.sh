#!/bin/bash

echo "Pivotal Network Download Tool"
echo "Be prepared with your Authorization Token, API Download URL, and Filename"

echo ""
echo "Enter your Authorization Token:"
read AUTHTOKEN
echo ""
echo "Enter the API Download URL:"
read APIURL
echo ""
echo "Enter the Filename:"
read FILENAME

wget --post-data="" --header="Authorization: Token $AUTHTOKEN" $APIURL -O "$FILENAME"

#wget --post-data="" --header="Authorization: Token iigMJxjc3wkqxRiknHR1" https://network.pivotal.io/api/v2/products/pivotal-container-service/releases/92793/product_files/130381/download -O "pivotal-container-service-1.0.3-build.15.pivotal"
