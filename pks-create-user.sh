#!/bin/bash

APIFQDN="pksapi.lab.azure.harnessingunicorns.io"
UAA_ADMIN_SECRET=""
USERNAME=""
EMAIL=""
PASSWORD=""
PKS_SCOPE="pks.clusters.admin" # or pks.clusters.manage

uaac target ${APIFQDN}:8443 --skip-ssl-validation
uaac token client get admin -s ${UAA_ADMIN_SECRET}

uaac user add ${USERNAME} --emails ${EMAIL} -p ${PASSWORD}
uaac member add pks.clusters.admin ${USERNAME}


