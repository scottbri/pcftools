#!/bin/bash

DEBUG=0
DEBUGFILE="initialize_iaas.log"

# A little function to ask a user for input
# always returns 0, but echo's the user's sanitized response for capture as a string by the caller
askUser() {
	read -p "$1"": " __val
	# first, strip underscores
	CLEAN=${__val//_/}
	# next, replace spaces with underscores
	CLEAN=${CLEAN// /_}
	# now, clean out anything that's not alphanumeric or an underscore or a hyphen
	CLEAN=${CLEAN//[^a-zA-Z0-9_-]/}
	echo "${CLEAN}"

	return 0
}

# A little more function based on askUser() to specifically ask a yes or no question
# returns 0 for Yes or 1 for "not yes"
askYes() {
	CLEAN="$(askUser "$1 (Y|y) ")"
	if [ "$CLEAN" == "${CLEAN#[Yy]}" ]; then
		return 1
	else
		return 0
	fi
}	

IAAS="azure"
ENV_NAME="$(askUser "Decide on a short subdomain name (like \"pcf\") for the environment? ")"

AZURE_REGION="${AZURE_REGION:-UNSET}"
AZURE_SUBSCRIPTION_ID="${AZURE_SUBSCRIPTION_ID:-UNSET}"
AZURE_TENANT_ID="${AZURE_TENANT_ID:-UNSET}"
AZURE_CLIENT_ID="${AZURE_CLIENT_ID:-UNSET}"
AZURE_CLIENT_SECRET="${AZURE_CLIENT_SECRET:-UNSET}"

echo "Here are how the required environment variables to bbl up on $IAAS are currently set:"
echo "IAAS=$IAAS"
echo "ENV_NAME=$ENV_NAME"
echo "AZURE_REGION=$AZURE_REGION"
echo "AZURE_SUBSCRIPTION_ID=$AZURE_SUBSCRIPTION_ID"
echo "AZURE_TENANT_ID=$AZURE_TENANT_ID"
echo "AZURE_CLIENT_ID=$AZURE_CLIENT_ID"
echo "AZURE_CLIENT_SECRET=$AZURE_CLIENT_SECRET"
	
echo ""; askYes "Would you like to continue and get help populating these values?"; RETVAL=$?
if [[ $RETVAL -eq 1 ]]; then echo "Ok then.  Good luck on $IAAS!"; exit 0; fi

sleep 1; echo ""; echo "Great!  Let's continue."
AZURE_CLIENT_SECRET="$(askUser "Please enter a complex secret alphanumeric password for your new Active Directory application")"
	
sleep 1; echo "Thanks!  Now we'll make sure you're logged into Azure.  Please follow the prompts to login:"
echo "=========="
echo '$ az login'
az login 2>&1
sleep 1; echo ""; echo "=========="; echo "... and we're back"

sleep 1; echo ""; echo "Here is a list of locations (regions) where BOSH can be deployed"
echo '$ az account list-locations | jq -r .[].name'
az account list-locations | jq -r .[].name
AZURE_REGION="$(askUser "Please input the name of one of these regions for the deployment")"

sleep 1; echo ""; echo "I'm querying Azure for your default Subscription ID and Tenant ID"
echo '$ az account list --all'
AZ_ACCOUNT_LIST="`az account list --all`"
export AZURE_SUBSCRIPTION_ID="`echo \"$AZ_ACCOUNT_LIST\" | jq -r '.[] | select(.isDefault) | .id'`"
echo "Your AZURE_SUBSCRIPTION_ID is $AZURE_SUBSCRIPTION_ID:"

export AZURE_TENANT_ID="`echo \"$AZ_ACCOUNT_LIST\" | jq -r '.[] | select(.isDefault) | .tenantId'`"
echo "Your AZURE_TENANT_ID is $AZURE_TENANT_ID"
if [ $DEBUG ]; then echo "$AZ_ACCOUNT_LIST" >> $DEBUGFILE; fi


AZURE_SP_DISPLAY_NAME="Service Principal for BOSH"
AZURE_SP_HOMEPAGE="http://BOSHAzureCPI"
AZURE_SP_IDENTIFIER_URI="http://BOSHAzureCPI-$RANDOM"
AZURE_OUTPUTFILE_JSON="service-principal.json"

echo ""; echo "Creating an Active Directory application to generate a new Application ID"
echo "$ az ad app create --display-name \"$AZURE_SP_DISPLAY_NAME\" \\"
echo "	--password \"$AZURE_CLIENT_SECRET\" --homepage \"$AZURE_SP_HOMEPAGE\" \\"
echo "	--identifier-uris \"$AZURE_SP_IDENTIFIER_URI\""
askYes "Are you good with me issuing the above command?"; RETVAL=$?
if [[ $RETVAL -eq 1 ]]; then echo "Bailing out now!  Good luck bbl-ing up on $IAAS!"; exit 1; fi
AZ_AD_APP_CREATE="`az ad app create --display-name \"$AZURE_SP_DISPLAY_NAME\" \
	--password \"$AZURE_CLIENT_SECRET\" --homepage \"$AZURE_SP_HOMEPAGE\" \
	--identifier-uris \"$AZURE_SP_IDENTIFIER_URI\"`"
export AZURE_CLIENT_ID="`echo \"$AZ_AD_APP_CREATE\" | jq -r '.appId'`"
echo "Your AZURE_CLIENT_ID is $AZURE_CLIENT_ID"
if [ $DEBUG ]; then echo "$AZ_AD_APP_CREATE" >> $DEBUGFILE; fi

echo ""; echo "Creating the Service Principal corresponding to the new Application"
echo "$ az ad sp create --id $AZURE_CLIENT_ID"
askYes "Are you good with me issuing the above command?"; RETVAL=$?
if [[ $RETVAL -eq 1 ]]; then echo "Bailing out now!  Good luck bbl-ing up on $IAAS!"; exit 1; fi
AZ_AD_SP_CREATE="`az ad sp create --id $AZURE_CLIENT_ID`"
if [ $DEBUG ]; then echo "$AZ_AD_SP_CREATE" >> $DEBUGFILE; fi

echo ""; echo "Sleeping 45 seconds to let Azure AD catch up before proceeding"
sleep 45
echo ""; echo "Assigning the Service Principal to the Contributor Role"
echo "$ az role assignment create --assignee $AZURE_CLIENT_ID --role Contributor --scope /subscriptions/$AZURE_SUBSCRIPTION_ID"
askYes "Are you good with me issuing the above command?"; RETVAL=$?
if [[ $RETVAL -eq 1 ]]; then echo "Bailing out now!  Good luck bbl-ing up on $IAAS!"; exit 1; fi
AZ_ROLE_ASSIGNMENT_CREATE="`az role assignment create --assignee $AZURE_CLIENT_ID --role Contributor --scope /subscriptions/$AZURE_SUBSCRIPTION_ID`"
if [ $DEBUG ]; then echo "$AZ_ROLE_ASSIGNMENT_CREATE" >> $DEBUGFILE; fi

echo ""; echo "Registering the Subscription with Microsoft Storage, Network, and Compute"
echo "$ az provider register --namespace Microsoft.Storage"
echo "$ az provider register --namespace Microsoft.Network"
echo "$ az provider register --namespace Microsoft.Compute"
askYes "Are you good with me issuing the above three (3) commands?"; RETVAL=$?
if [[ $RETVAL -eq 1 ]]; then echo "Bailing out now!  Good luck bbl-ing up on $IAAS!"; exit 1; fi
az provider register --namespace Microsoft.Storage
az provider register --namespace Microsoft.Network
az provider register --namespace Microsoft.Compute

echo "Finished!  Here are the settings and credentials in the form of environment variables you can set"
echo "Archive these for posterity!"
echo ""
{
echo "export IAAS=$IAAS"
echo "export ENV_NAME=$ENV_NAME"
echo "export STATE_DIRECTORY=$STATE_DIRECTORY"
echo "export AZURE_REGION=$AZURE_REGION"
echo "export AZURE_SUBSCRIPTION_ID=$AZURE_SUBSCRIPTION_ID"
echo "export AZURE_TENANT_ID=$AZURE_TENANT_ID"
echo "export AZURE_APPLICATION_ID=$AZURE_CLIENT_ID"
echo "export AZURE_CLIENT_ID=$AZURE_CLIENT_ID"
echo "export AZURE_CLIENT_SECRET=$AZURE_CLIENT_SECRET"
} | tee $ENVIRONMENT_VARS

echo ""
echo "Writing a terraform.tfvars based on these values.  Edit before use!"
cat <<EOF > terraform.tfvars
subscription_id       = "$AZURE_SUBSCRIPTION_ID"
tenant_id             = "$AZURE_TENANT_ID"
client_id             = "$AZURE_CLIENT_ID"
client_secret         = "$AZURE_CLIENT_SECRET"

env_name              = "$ENV_NAME"
env_short_name        = "$ENV_NAME"
location              = "$AZURE_REGION"
ops_manager_image_uri = "https://opsmanagereastus.blob.core.windows.net/images/ops-manager-2.4-build.142.vhd"
dns_suffix            = "azure.harnessingunicorns.io"
vm_admin_username     = "admin"
EOF
