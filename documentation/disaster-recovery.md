# SMTP Relay disaster recovery

*It is recommended to roll forward with a fix than to roll back. If a rollback is still required, follow the steps in this guide*

The SMTP service has no persistent data which means that the code which is stored in the repositories is all thats needed to bring the service back online.

## Prerequisites

- Complete the prerequisites [here](https://github.com/ministryofjustice/staff-infrastructure-smtp-relay-server#prerequisites)
- Access to the existing AWS account with [AWS BYOIP](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-byoip.html) addresses in order to be able to send on mail to ExchangeOnline/GoogleWorkspace. If this is not possible the new Elastic Public IPs will need to be replaced on `mail-relay.staff.service.justice.gov.uk` PTR records within Route53 else mail delivery will fail.
- If account has lost attachment to transit gateway then `push` access to the [transit gateway repo](https://github.com/ministryofjustice/deployment-tgw).

## Recovering from a disaster
In the event that Grafana has alerted on a disaster scenario, find we can follow the below guides to restore service.

### 1. Restore the ECS infrastructure
We first need to deploy the underlying AWS infrastructure, we can follow the [How to deploy the Infrastructure](https://github.com/ministryofjustice/staff-infrastructure-network-services/blob/main/documentation/how-to-deploy-the-infrastructure.md) to get this up and running.


### 2. Restore the postfix server
Once the AWS infrastructure is deployed we can restore the Postfix SMTP server container into ECS Fargate by following the [Deploy SMTP Relay Server](https://github.com/ministryofjustice/staff-infrastructure-smtp-relay-server)