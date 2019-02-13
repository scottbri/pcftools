gcloud compute networks peerings create default-to-${PCF_SUBDOMAIN_NAME}-pcf-network \
  --network=default \
  --peer-network=${PCF_SUBDOMAIN_NAME}-pcf-network \
  --auto-create-routes

gcloud compute networks peerings create ${PCF_SUBDOMAIN_NAME}-pcf-network-to-default \
  --network=${PCF_SUBDOMAIN_NAME}-pcf-network \
  --peer-network=default \
  --auto-create-routes

gcloud compute --project=${PCF_PROJECT_ID} firewall-rules create ${PCF_SUBDOMAIN_NAME}-bosh \
 --direction=INGRESS \
 --priority=1000 \
 --network=${PCF_SUBDOMAIN_NAME}-pcf-network \
 --action=ALLOW \
 --rules=tcp:25555,tcp:8443,tcp:22 \
 --source-ranges=0.0.0.0/0


