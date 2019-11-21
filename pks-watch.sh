#!/bin/bash

set -e

#Usage function
function usage {
	echo ""
	echo "Usage: $0 <cluster-name> "
	echo ""
	echo "where:"
	echo "     cluster-name:  the new pks cluster to be monitored for status change"
	echo ""
	echo "Notes on setup prior to usage:"
	echo "Start by configuring PKS API access"
	echo "  $ pks login -a PKS-API -u USERNAME -k"
	echo ""
}

if [ $# -lt 1 ] ; then
    usage
    exit 1
fi

# GLOBALS
CLUSTER_NAME=$1
CLUSTER_STATUS=""

if ! [ -x "$(command -v jq)" ]; then
  echo 'ERROR: jq is not installed.' >&2
  exit 1
fi

if ! [ -f "${HOME}/.pks/creds.yml" ]; then
  echo "ERROR: Login to PKS API before proceeding" >&2
  exit 1
fi


function wait_for_it {
  WAIT=10
  MAXWAIT=1800  # 1800 seconds is 30 minutes
  # uses global variables

  ORIG_CLUSTER_STATUS=$(pks cluster $CLUSTER_NAME --json  | jq  -r .last_action_state)
  CLUSTER_STATUS="$ORIG_CLUSTER_STATUS"
  echo "Cluster status is \"$CLUSTER_STATUS\" at `date`"
  echo -n "Monitoring for status change every ${WAIT} seconds: ."
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

wait_for_it
