#!/bin/bash


if [ $# -lt 3 ] ; then
	echo "Usage: $0 <Auth_Token> <API_URL> <Filename>"
	echo ""
	echo "where:"
	echo "     Auth_Token: the LEGACY API TOKEN [DEPRECATED] from Pivnet"
	echo "     API_URL:    the API Download URL from the Pivnet info box"
	echo "     Filename:   the file name from the Pivnet info box"
	echo ""
	exit 1
fi

AUTHTOKEN="$1"
APIURL="$2"
FILENAME="$3"

wget --post-data="" --header="Authorization: Token $AUTHTOKEN" $APIURL -O "$FILENAME"

