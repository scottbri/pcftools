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

