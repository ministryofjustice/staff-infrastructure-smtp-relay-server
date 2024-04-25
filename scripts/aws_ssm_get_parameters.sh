#!/usr/bin/env bash

export PARAM=$(aws ssm get-parameters --region eu-west-2 --with-decryption --names \
    "/codebuild/pttp-ci-infrastructure-net-svcs-core-pipeline/shared_services_base_repository_url" \
    "/codebuild/pttp-ci-infrastructure-net-svcs-core-pipeline/$ENV/public_dns_zone_name_staff_service" \
    "/codebuild/pttp-ci-infrastructure-net-svcs-core-pipeline/$ENV/relay_domain" \
    "/codebuild/pttp-ci-infrastructure-net-svcs-core-pipeline/$ENV/o365_smart_host" \
    "/codebuild/staff_device_shared_services_account_id" \
    --query Parameters)

declare -A params

params["REGISTRY_URL"]="$(echo $PARAM | jq '.[] | select(.Name | test("shared_services_base_repository_url")) | .Value' --raw-output)"
params["PUBLIC_DNS_ZONE_NAME_STAFF_SERVICE"]="$(echo $PARAM | jq '.[] | select(.Name | test("public_dns_zone_name_staff_service")) | .Value' --raw-output)"
params["RELAY_DOMAIN"]="$(echo $PARAM | jq '.[] | select(.Name | test("relay_domain")) | .Value' --raw-output)"
params["O365_SMART_HOST"]="$(echo $PARAM | jq '.[] | select(.Name | test("o365_smart_host")) | .Value' --raw-output)"
params["SHARED_SERVICES_ACCOUNT_ID"]="$(echo $PARAM | jq '.[] | select(.Name | test("staff_device_shared_services_account_id")) | .Value' --raw-output)"
