#!/bin/bash

if [ $# -lt 2 ] ; then
	echo "Usage: $0 <project> <username>"
	echo ""
	echo "where:"
	echo "     project:   the google project where all will be deployed"
	echo "     username:  the new service account user name"
	echo ""
	exit 1
fi

PROJECT="$1"
USERNAME="$2"
FILENAME="${USERNAME}-terraform-json.key"

gcloud iam service-accounts create ${USERNAME} --display-name "${USERNAME} Service Account"
gcloud iam service-accounts keys create "${FILENAME}" --iam-account "${USERNAME}@${PROJECT}.iam.gserviceaccount.com"
gcloud projects add-iam-policy-binding ${PROJECT} --member "serviceAccount:${USERNAME}@${PROJECT}.iam.gserviceaccount.com" --role 'roles/owner'
