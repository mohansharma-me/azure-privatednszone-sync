#!/bin/bash
# Pre: jq, httpie
echo "Running at $(date)"
. ~/dns.config
printf "Generating access token..."
AUTH=$(http POST https://login.microsoftonline.com/${TENANT_ID}/oauth2/token content-type:"application/x-www-form-urlencoded" grant_type=client_credentials client_id="${CLIENT_ID}" client_secret="${CLIENT_SECRET}" resource="https://management.azure.com" --form)
ACCESS_TOKEN=$(echo "${AUTH}" | jq -r '.access_token')
printf " received of length : %s\n" "${#ACCESS_TOKEN}"
printf "Requesting DNS records..."
DNS_RESPONSE=$(http GET https://management.azure.com/subscriptions/${SUBSCRIPTION_ID}/resourceGroups/${RESOURCE_GROUP}/providers/Microsoft.Network/privateDnsZones/${ZONE_NAME}/ALL api-version==2018-09-01 Authorization:"Bearer ${ACCESS_TOKEN}")
printf " received of length : %s\n" "${#DNS_RESPONSE}"
RECORDS=$(echo "${DNS_RESPONSE}" | jq -c '.value[]')
for RECORD in ${RECORDS}; do
  RECORD_TYPE=$(echo "${RECORD}" | jq -r '.type')
  if [ "${RECORD_TYPE}" == "Microsoft.Network/privateDnsZones/A" ]; then
    FQDN=$(echo "${RECORD}" | jq -r '.properties.fqdn' | sed -e "s@${ZONE_NAME}.@${ZONE_NAME}@g")
    IPV4=$(echo "${RECORD}" | jq -r '.properties.aRecords[0].ipv4Address')
    if [ -z "${FQDN}" -a -z "${IPV4}" ]; then
      echo "Error record : ${RECORD}"
    else
      printf "Found A record : %s (%s) = patching" "${FQDN}" "${IPV4}"
      sed -i -e "s@.*${FQDN}@@g" /etc/hosts
      echo "${IPV4} ${FQDN}" >>/etc/hosts
      printf "\b\b\b%s \n" "ed"
    fi
  fi
done
sed -i -e "/^# Last updated at.*/d" /etc/hosts
echo "# Last updated at $(date)" >>/etc/hosts
sed -i -e "/^$/d" /etc/hosts
printf "Process completed at %s\n" "$(date)"
