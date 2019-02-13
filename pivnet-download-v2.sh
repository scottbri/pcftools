#!/bin/bash


if [ $# -lt 4 ] ; then
	echo "Usage: $0 <UAA_API_TOKEN> <PRODUCT_SLUG> <RELEASE_ID> <FILENAME>"
	echo ""
	echo "where:"
	echo "     UAA_API_TOKEN: <Request New Refresh Token> from"
	echo "                    https://network.pivotal.io/users/dashboard/edit-profile"
	echo "     PRODUCT_SLUG:  the text element after /products/ in the pivnet url"
	echo "     RELEASE_ID:    the number after /products/*/releases/ in the pivnet url"
	echo "     FILENAME:      the filename to match from the release bundle"
	echo ""
	exit 1
fi

PCF_PIVNET_UAA_TOKEN="$1"
PRODUCT_SLUG="$2"
RELEASE_ID="$3"
FILENAME_STRING="$4"

# Authenticate with the UAA_TOKEN and capture response
echo ""
echo Authenticate with the UAA_TOKEN and capture response
AUTHENTICATION_RESPONSE=$(curl \
  --fail \
  --data "{\"refresh_token\": \"${PCF_PIVNET_UAA_TOKEN}\"}" \
  https://network.pivotal.io/api/v2/authentication/access_tokens)

# Parse pivnet access token from the response
echo ""
echo Parse pivnet access token from the response
PIVNET_ACCESS_TOKEN=$(echo ${AUTHENTICATION_RESPONSE} | jq -r '.access_token')

# Capture the JSON response from the PRODUCT_SLUG and RELEASE in question
echo ""
echo Capture the JSON response from the PRODUCT_SLUG and RELEASE in question
RELEASE_JSON=$(curl \
  --fail \
  "https://network.pivotal.io/api/v2/products/${PRODUCT_SLUG}/releases/${RELEASE_ID}")

# Parse the EULA URL to accept
echo ""
echo Parse the EULA URL to accept
EULA_ACCEPTANCE_URL=$(echo ${RELEASE_JSON} |\
  jq -r '._links.eula_acceptance.href')

# Accept the EULA for the PRODUCT_SLUG and RELEASE
echo ""
echo Accept the EULA for the PRODUCT_SLUG and RELEASE
curl \
  --fail \
  --header "Authorization: Bearer ${PIVNET_ACCESS_TOKEN}" \
  --request POST \
  ${EULA_ACCEPTANCE_URL}

# Parse the release and capture the specific file element JSON
echo ""
echo Parse the release and capture the specific file element JSON
DOWNLOAD_ELEMENT=$(echo ${RELEASE_JSON} |\
  jq -r --arg FILENAMESTR "$FILENAME_STRING" '.product_files[] | select(.aws_object_key | contains($FILENAMESTR))')

# Parse the DOWNLOAD_ELEMENT JSON and capture the filename
echo ""
echo Parse the DOWNLOAD_ELEMENT JSON and capture the filename
FILENAME=$(echo ${DOWNLOAD_ELEMENT} |\
  jq -r '.aws_object_key | split("/") | last')

# Parse the DOWNLOAD_ELEMENT and capture the URL
echo ""
echo Parse the DOWNLOAD_ELEMENT and capture the URL
URL=$(echo ${DOWNLOAD_ELEMENT} |\
  jq -r '._links.download.href')

# Download the desired file
echo ""
echo Download the desired file
curl \
  --fail \
  --location \
  --output ${FILENAME} \
  --header "Authorization: Bearer ${PIVNET_ACCESS_TOKEN}" \
  ${URL}

