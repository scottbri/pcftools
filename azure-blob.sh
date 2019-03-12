#!/bin/bash
# A simple Azure Storage example script
export AZURE_STORAGE_ACCOUNT=prodlabblobstore
export AZURE_STORAGE_KEY="+QPtMmVujLeaOVAYtU/ixAty7qa9Nu5J3wu3FjcdgFutwom6oiZRN/B5nmHu1V2wZ53tS7aY3oZEI/3Ilwwrhw=="

export container_name=artifacts
export blob_name=tester
export file_to_upload=production.tar.gz
export destination_file=tester.tar.gz

echo "Creating the container..."
az storage container create --name $container_name

echo "Uploading the file..."
az storage blob upload --container-name $container_name --file $file_to_upload --name $blob_name

echo "Listing the blobs..."
az storage blob list --container-name $container_name --output table

echo "Downloading the file..."
az storage blob download --container-name $container_name --name $blob_name --file $destination_file --output table

echo "Done"

