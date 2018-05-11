#!/bin/bash

echo "In which GCP Project will this account reside:"
read PROJECT
echo ""
echo "What username do you want for this service account:"
read USERNAME
echo ""
echo "What filename will the json key be written:"
read FILENAME
echo ""

gcloud iam service-accounts create ${USERNAME} --display-name "${USERNAME} Service Account"
gcloud iam service-accounts keys create "${FILENAME}" --iam-account "${USERNAME}@${PROJECT}.iam.gserviceaccount.com"
gcloud projects add-iam-policy-binding ${PROJECT} --member "serviceAccount:${USERNAME}@${PROJECT}.iam.gserviceaccount.com" --role 'roles/owner'
