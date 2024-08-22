[![repo standards badge](https://img.shields.io/badge/dynamic/json?color=blue&style=flat&logo=github&labelColor=32393F&label=MoJ%20Compliant&query=%24.result&url=https%3A%2F%2Foperations-engineering-reports.cloud-platform.service.justice.gov.uk%2Fapi%2Fv1%2Fcompliant_public_repositories%2Fstaff-infrastructure-smtp-relay-server)](https://operations-engineering-reports.cloud-platform.service.justice.gov.uk/public-github-repositories.html#staff-infrastructure-smtp-relay-server "Link to report")

# Staff Infrastructure SMTP Relay Server  

## Introduction  

This repository builds the docker image for the SMTP Relay Server and pushes it to the Shared Services Elastic Container Repository, so that the pre-configured ECS task can pull down this image and launch a new container.  


## SMTP Relay Server

The SMTP Relay Server enables devices which are unable to use authentication to use unauthenticated SMTP to send email.

Currently, printers and a few legacy applications from various MoJ HQ sites are using this SMTP relay service via the Transit Gateway to send emails to both justice and digital domains.

### High Level Architecture

This service consists of an AWS ECS cluster running two instances of SMTP Relay Server containers with postfix image in two availibilty zones in London region. Two load balancers from those two availibility zones are there to accept incoming requests from clients via the Transit gateway and then to distribute the requests to those SMTP Relay Server containers. This provides high availibility and resiliency to the service.

Here is a diagram:

![staff-infrastructure-network-services-architecture](diagrams/staff-infrastructure-network-services-architecture.png)  
[Diagram source](diagrams/staff-infrastructure-network-services-architecture.drawio)


## 

This repository depends on the network services infrastructure repository, which builds the underlying base infrastructure with required ECR repository and ECS service definitions to work with this docker image.  

## Related Repositories  

This repository builds the docker image for SMTP Relay server only. Here are some of the other related repositories:  

- [staff-device-shared-services-infrastructure](https://github.com/ministryofjustice/staff-device-shared-services-infrastructure)  
- [staff-infrastructure-network-services](https://github.com/ministryofjustice/staff-infrastructure-network-services)

## Technical Guide  

Once you have deployed the infrastructure, you may use this guide to build and push the SMTP Relay server image.  

### Prerequisites

To be able to follow this guide, you need to have the following already:  
 
- [System infrastructure deployed](https://github.com/ministryofjustice/staff-infrastructure-network-services/blob/main/documentation/how-to-deploy-the-infrastructure.md)
- [Docker](https://www.docker.com/)
- [AWS Vault](https://github.com/99designs/aws-vault#installing) set up.  
- Access to [Moj AWS SSO](https://moj.awsapps.com/start#/).  
- [jq](https://stedolan.github.io/jq/download/) installed.

| :tada: TIP |  
|:-----|  
| You may configure your AWS Vault to use AWS SSO. A [step-by-step guide](https://ministryofjustice.github.io/cloud-operations/documentation/team-guide/best-practices/use-aws-sso.html#re-configure-aws-vault) can be found in our team documentation site. |  

### Prepare the variables  

1. Clone this repo to a local directory.  
1. Copy `.env.example` to `.env`.  
1. Modify the `.env` file and replace all placeholders with correct values.  

### Authenticate Docker with AWS ECR

The Docker base image is stored in ECR. Prior to building the container you must authenticate Docker to the ECR registry. [Details can be found here](https://docs.aws.amazon.com/AmazonECR/latest/userguide/Registries.html#registry_auth).

If you have [aws-vault](https://github.com/99designs/aws-vault#installing) configured with credentials for shared services, do the following to authenticate:

```bash
make authenticate-docker
```  

### Build the image  

4. To build the image on your local docker, run:  

```shell
make build-dev
```  

### Run the server locally  

5. To run the SMTP Relay server on your local docker, run:  

```shell
make run
```

### Test locally  

6. To test the build locally, run:  

```shell
make test
```  

### Push your docker image  

7. To push the built image on to your isolated ECR repository, run:  

```shell  
make publish  
```  

### Deploy a force remote ECS restart  

```shell
make deploy  
```  

### Stopping Local Environment

Once you have finished using the docker image, to shut down the environment, run:  

```shell  
make stop  
```  


# SMTP Relay disaster recovery

*In the event of disaster recovery for the SMTP Relay Server it is recommended to roll forward with a fix than to roll back. If a rollback is still required, follow the steps in this guide*

The SMTP service has no persistent data which means that the code which is stored in the repositories is all that is needed to bring the service back online.

## Prerequisites

- Complete the prerequisites steps [here](https://github.com/ministryofjustice/staff-infrastructure-smtp-relay-server#prerequisites)
- Access to the existing AWS account with [AWS BYOIP](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-byoip.html) addresses in order to be able to send on mail to ExchangeOnline/GoogleWorkspace. If this is not possible the new Elastic Public IPs will need to be replaced on `mail-relay.staff.service.justice.gov.uk` PTR records within Route53 else mail delivery will fail.
- If account has lost attachment to transit gateway then `push` access to the [transit gateway repo](https://github.com/ministryofjustice/deployment-tgw).

## Recovering from a disaster
In the event that Grafana has alerted on a disaster scenario, follow the steps below to restore service.

### 1. Restore the ECS infrastructure
Deploy the underlying AWS infrastructure by following the [How to deploy the Infrastructure](https://github.com/ministryofjustice/staff-infrastructure-network-services/blob/main/documentation/how-to-deploy-the-infrastructure.md) guide.


### 2. Restore the postfix server
Once the AWS infrastructure is deployed, restore the Postfix SMTP server container into ECS Fargate by following the [Deploy SMTP Relay Server](https://github.com/ministryofjustice/staff-infrastructure-smtp-relay-server) guide.