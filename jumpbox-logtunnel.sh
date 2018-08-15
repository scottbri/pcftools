#!/bin/bash

if [ $# -lt 2 ] ; then
	echo "Usage: $0 <SSHSTRING> <jumpbox_private_key "
	echo ""
	echo "where:"
	echo "     SSHSTRING:      the user@domain name or IP of the jump box (ubuntu@pcf.examnple.com)"
	echo "     jumpbox_private_key:  file from \"terraform output ops_manager_ssh_private_key\" > file"
	echo ""
	exit 1
fi

SSHSTRING=$1
JUMPBOXKEY=$2


#terraform output ops_manager_ssh_private_key > $JUMPBOXKEY
#chmod 400 $JUMPBOXKEY

ssh -N -D 9999 $SSHSTRING -i $JUMPBOXKEY -f

#bosh -e 10.0.0.10 alias-env zeta --ca-cert ~/Downloads/zeta-root-ca-cert.txt 

