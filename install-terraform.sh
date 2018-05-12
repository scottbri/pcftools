#!/bin/bash

echo "Downloading Terraform 64bit for Linux from https://www.terraform.io/downloads.html"
wget https://releases.hashicorp.com/terraform/0.11.7/terraform_0.11.7_linux_amd64.zip

echo ""
echo "unzipping the Terraform .zip package"
unzip terraform*.zip

echo ""
echo "Moving the terraform binary to /usr/local/bin"
sudo mv terraform /usr/local/bin

echo "Removing the terraform ZIP package"
rm terraform*.zip

echo "Executing Terraform to make sure it's in the path and executable."
echo "You should see the usage help text from terraform"
terraform
