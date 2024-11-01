#!/usr/bin/env bash

## This script will generate .env file for use with the Makefile
## or to export the TF_VARS into the environment

set -x

export ENV="${1:-development}"

printf "\n\nEnvironment is %s\n\n" "${ENV}"

case "${ENV}" in
    development)
        echo "development -- Continuing..."
        ;;
    pre-production)
        echo "pre-production -- Continuing..."
        ;;
    production)
        echo "production shouldn't be running this locally. Exiting..."
        exit 1
        ;;
    *)
        echo "Invalid input."
        ;;
esac

echo "Press 'y' to continue or 'n' to exit."

# Wait for the user to press a key
read -s -n 1 key

# Check which key was pressed
case $key in
    y|Y)
        echo "You pressed 'y'. Continuing..."
        ;;
    n|N)
        echo "You pressed 'n'. Exiting..."
        exit 1
        ;;
    *)
        echo "Invalid input. Please press 'y' or 'n'."
        ;;
esac

# run aws_ssm_get_parameters.sh
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
SCRIPT_PATH="${SCRIPT_DIR}/aws_ssm_get_parameters.sh"
. "${SCRIPT_PATH}"


cat << EOF > ./.env
# env file
# regenerate by running "./scripts/generate-env-file.sh"
# defaults to "development"
# To test against another environment
# regenerate by running "./scripts/generate-env-file.sh [pre-production | production]"
# Also run "make clean"


AWS_PROFILE=mojo-shared-services-cli
AWS_VAULT_PROFILE=mojo-shared-services-cli
ENV=${ENV}

## These values need to be added manually
TEST_SENDER_EMAIL_ADDRESS=testuser@devl.justice.gov.uk

O365_TEST_RECIPIENT_EMAIL_ADDRESS=sandhya.buddharaju@justrice.gov.uk
GOOGLE_TEST_RECIPIENT_EMAIL_ADDRESS=lanwifi-devops@digital.justice.gov.uk
OTHER_TEST_RECIPIENT_EMAIL_ADDRESS=sandhyab1506@yahoo.com

## These values below are retrieved from the AWS Parameter Store
EOF

for key in "${!params[@]}"
do
  echo "${key}=${params[${key}]}"  >> ./.env
done

chmod u+x ./.env
