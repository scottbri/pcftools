#!/bin/bash

set -e

#Usage function
function usage {
	echo ""
	echo "Usage: $0 {provision|access|cleanup|destroy} <cluster-name> [plan-name]"
	echo ""
	echo "where:"
	echo "     provision:     create a new pks cluster with load balancer"
	echo "     access:        create a load balancer for an existing pks cluster"
	echo "     cleanup:       delete the load balancers for a cluster"
	echo "     destroy:       executes cleanup and interactive pks delete-cluster"
	echo "     cluster-name:  the new k8s cluster to be provisioned"
	echo "     plan-name:     the plan to use creating the cluster"
	echo ""
	echo "Notes on setup prior to usage:"
	echo "Start by configuring PKS API access"
	echo "  $ pks login -a PKS-API --client-name CLIENT-NAME --client-secret CLIENT-SECRET -k"
	echo "Configure GCP SDK client, log in to GCP"
	echo "  $ gcloud auth login"
	echo "Configure GCP compute region, same as AZ configuration for PKS tile"
	echo "  $ gcloud config set compute/region GCP_REGION"
	echo ""
	echo ""
}

if [ $# -lt 2 ] ; then
    usage
    exit 1
fi

# GLOBALS
OPERATION=$1
CLUSTER_NAME=$2
CLUSTER_PLAN=$3
CLUSTER_REGION=$(gcloud config list --format="value(compute.region)")
CLUSTER_STATUS=""

if [[ "$CLUSTER_REGION" == "" ]]; then
  echo "ERROR: Configure GCP region, check step 3 on Instructions!!" >&2
  exit 1
fi

if ! [ -x "$(command -v jq)" ]; then
  echo 'ERROR: jq is not installed.' >&2
  exit 1
fi

if ! [ -f "${HOME}/.pks/creds.yml" ]; then
  echo "ERROR: Login to PKS API before proceeding" >&2
  exit 1
fi



#Function to reserve IP on GCP & create cluster
function provision_cluster {

  LB_NAME="$CLUSTER_NAME-lb"
  # uses global variables

  echo -n "Reserving public IP for cluster load balancer"
  gcloud compute addresses create $LB_NAME --region=$CLUSTER_REGION
  CLUSTER_IP=$(gcloud compute addresses describe $LB_NAME --region=$CLUSTER_REGION --format="value(address)")

  echo -e "\nCreating PKS cluster $CLUSTER_NAME with external hostname $CLUSTER_IP.xip.io"
  pks create-cluster $CLUSTER_NAME --external-hostname $CLUSTER_IP.xip.io -p $CLUSTER_PLAN
}

#Function to enable access to pks cluster on gcp
function enable_access {

  LB_NAME="$CLUSTER_NAME-lb"
  FORWARDING_RULE="pks-$CLUSTER_NAME-forwarding-rule"
  # uses global variables

  if ! [[ "$(gcloud compute target-pools list --filter="name=$LB_NAME" --format="value(name)")" == "" ]]; then
    echo -e "\nLoad balancer $LB_NAME already exists..."
  else
    echo -e "\nProvisioning load balancer for $CLUSTER_NAME pks cluster"
    gcloud compute target-pools create $LB_NAME \
      --description="Load balancer for $CLUSTER_NAME pks cluster" \
      --region=$CLUSTER_REGION
  fi

  if ! [[ "$(gcloud compute forwarding-rules list --filter="name=$FORWARDING_RULE" --format="value(name)")" == "" ]]; then
    echo -e "\nForwarding rule $FORWARDING_RULE already exists..."
  else
    echo -e "\nConfiguring forwarding rule for $LB_NAME"
    gcloud compute forwarding-rules create $FORWARDING_RULE \
      --region=$CLUSTER_REGION \
      --address=$LB_NAME \
      --target-pool=$LB_NAME \
      --ports=8443
  fi

  echo -e "\nGetting master nodes for pks cluster $CLUSTER_NAME"

  CLUSTER_UUID=$(pks cluster $CLUSTER_NAME --json | jq -r .uuid)
  export BOSH_DEPLOYMENT_NAME=service-instance-$CLUSTER_UUID

  MASTERS=$(mktemp /tmp/master-$CLUSTER_UUID.XXXX)

  gcloud compute instances list --filter="labels.instance_group=master AND labels.deployment=$BOSH_DEPLOYMENT_NAME" \
    --format="csv[no-heading](name,zone,networkInterfaces.network)" > $MASTERS

  IFS=","
  while read -r instance zone network
  do
          echo -e "\nAdding $instance to load balancer $LB_NAME"
          gcloud --quiet compute target-pools add-instances $LB_NAME --instances=$instance --instances-zone=$zone

          echo -e "\nAdding tags for allowing traffic from load balancer"
          gcloud --quiet compute instances add-tags $instance --zone=$zone --tags $CLUSTER_NAME-master-access

  done < "$MASTERS"

  PKS_CLUSTER_NETWORK=$(basename $(head -1 $MASTERS | cut -d',' -f3))
  FW_RULE=$CLUSTER_NAME-fw-$CLUSTER_UUID

  if ! [[ "$(gcloud compute firewall-rules list --filter="name=$FW_RULE" --format="value(name)")" == "" ]]; then
    echo -e "\nFirewall rule $FW_RULE already exists..."
  else
    echo -e "\nCreating firewall rule from all sources to pks master nodes on port 8443"
    gcloud compute firewall-rules create  $FW_RULE --allow tcp:8443 \
          --description "Allow incoming traffic on TCP port 8443 for pks cluster $CLUSTER_NAME" \
          --target-tags "$CLUSTER_NAME-master-access" \
          --network $PKS_CLUSTER_NETWORK \
          --direction INGRESS
  fi

  rm $MASTERS

  echo -e "\nConfiguring kubectl for creds using pks get-credentials"
  pks get-credentials $CLUSTER_NAME

  echo -e "\nPKS cluster $CLUSTER_NAME information"
  kubectl cluster-info

  echo -e "\nGetting all pods across all namespaces..."
  kubectl get pods --all-namespaces
}

function gcp_cleanup {

  LB_NAME="$CLUSTER_NAME-lb"
  CLUSTER_UUID=$(pks cluster $CLUSTER_NAME --json | jq -r .uuid)
  # uses global variables

  echo "Deleting firewall rule"
  gcloud compute firewall-rules delete $CLUSTER_NAME-fw-$CLUSTER_UUID --quiet

  echo "Deleting forwarding rule"
  gcloud compute forwarding-rules delete pks-$CLUSTER_NAME-forwarding-rule --region=$CLUSTER_REGION --quiet

  echo "Deleting target pool/lb"
  gcloud compute target-pools delete $LB_NAME --quiet

  echo "Deleting $LB_NAME reserved IP addres"
  gcloud compute addresses delete $LB_NAME

}

function wait_for_it {
  WAIT=10
  MAXWAIT=1800  # 1800 seconds is 30 minutes
  # uses global variables

  ORIG_CLUSTER_STATUS=$(pks cluster $CLUSTER_NAME --json  | jq  -r .last_action_state)
  CLUSTER_STATUS="$ORIG_CLUSTER_STATUS"
  echo "Cluster status is \"$CLUSTER_STATUS\" at `date`"
  echo -n "Monitoring for status change..."
  while [ "$CLUSTER_STATUS" = "$ORIG_CLUSTER_STATUS" ]
  do
      sleep $WAIT
      echo -n "."

      CLUSTER_STATUS=$(pks cluster $CLUSTER_NAME --json  | jq  -r .last_action_state)
      MAXWAIT=$((MAXWAIT-$WAIT))
      if [ "$MAXWAIT" = "0" ]; then
        echo ""; echo "ERROR: Status has not changed.  Make sure it's working."
        exit 1 
      fi
  done
  echo "Cluster status changed to \"$CLUSTER_STATUS\" at `date`"
}

# already set $OPERATION = $1 above
case $OPERATION in
  provision)
    provision_cluster
    wait_for_it
    if [ "$CLUSTER_STATUS" = "succeeded" ]
    then
	enable_access
    else
	echo "ERROR:  Cluster $CLUSTER_NAME is reporting status $CLUSTER_STATUS.  Aborting."
    fi
    ;;
  access)
    wait_for_it
    if [ "$CLUSTER_STATUS" = "succeeded" ]
    then
	enable_access
    else
	echo "ERROR:  Cluster $CLUSTER_NAME is reporting status $CLUSTER_STATUS.  Aborting."
    fi
    ;;
  cleanup)
    gcp_cleanup
    ;;
  destroy)
    gcp_cleanup
    pks delete-cluster $CLUSTER_NAME
    ;;
  *)
    usage
    exit 1
esac
