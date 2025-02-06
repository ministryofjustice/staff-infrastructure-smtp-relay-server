#!/bin/bash

# This deployment script starts a zero downtime phased deployment.
# It works by doubling the currently running tasks by introducing the new versions
# Auto scaling will detect that there are too many tasks running for the current load and slowly start decomissioning the old running tasks
# Production traffic will gradually be moved to the new running tasks

set -euo pipefail

get_outputs() {
  printf "\nFetching terraform outputs for $ENV\n\n"
  terraform_outputs=`aws ssm get-parameter --name /codebuild/pttp-ci-infrastructure-net-svcs-core-pipeline/$ENV/terraform_outputs | jq -r .Parameter.Value`
}

assume_deploy_role() {
  role_arn=$(echo $terraform_outputs | jq '.assume_role.role_arn' | sed 's/"//g')
  temp_role=`aws sts assume-role --role-arn $role_arn --role-session-name ci-smtp-relay-deploy-$CODEBUILD_BUILD_NUMBER`
  aws_access_key_id=$(echo "${temp_role}" | jq -r '.Credentials.AccessKeyId')
  aws_secret_access_key=$(echo "${temp_role}" | jq -r '.Credentials.SecretAccessKey')
  aws_session_token=$(echo "${temp_role}" | jq -r '.Credentials.SessionToken')
}

deploy() {
  printf "\nFetching ECS cluster information for $ENV\n\n"
  cluster_name=$(echo $terraform_outputs | jq '.smtp_relay.ecs.cluster_name' | sed 's/"//g')
  service_name=$(echo $terraform_outputs | jq '.smtp_relay.ecs.service_name' | sed 's/"//g')

  printf "\nDeploying cluster service update for $ENV\n\n"
  AWS_ACCESS_KEY_ID=$aws_access_key_id AWS_SECRET_ACCESS_KEY=$aws_secret_access_key AWS_SESSION_TOKEN=$aws_session_token aws ecs update-service \
    --cluster $cluster_name \
    --service $service_name \
    --force-new-deployment
  
    # Wait for the ECS service to stabilize (reach steady state) add --max-wait 600 to cap at 10 mins?
  echo "Waiting for ECS service $service_name to reach steady state..."
  echo "$cluster_name"
  aws ecs wait services-stable --cluster "$cluster_name" --services "$service_name"

  if [ $? -eq 0 ]; then
    echo "ECS service $service_name has reached steady state."
  else
    echo "ECS service $service_name failed to reach steady state."
    exit 1
  fi

}

main() {
  get_outputs
  assume_deploy_role
  deploy
}

main
