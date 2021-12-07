# Staff Infrastructure SMTP Relay Server

This repo builds the docker image for the SMTP Relay server and pushes it to the Shared Services Elastic Container Repository, so that the pre-configured ECS task can pull down this image and launch a new container.
## Getting Started

### Authenticating Docker with AWS ECR

The Docker base image is stored in ECR. Prior to building the container you must authenticate Docker to the ECR registry. [Details can be found here](https://docs.aws.amazon.com/AmazonECR/latest/userguide/Registries.html#registry_auth).

If you have [aws-vault](https://github.com/99designs/aws-vault#installing) configured with credentials for shared services, do the following to authenticate:

```bash
aws-vault exec SHARED_SERVICES_VAULT_PROFILE_NAME -- aws ecr get-login-password --region eu-west-2 | docker login --username AWS --password-stdin SHARED_SERVICES_ACCOUNT_ID.dkr.ecr.eu-west-2.amazonaws.com
```

Replace ```SHARED_SERVICES_VAULT_PROFILE_NAME``` and ```SHARED_SERVICES_ACCOUNT_ID``` in the command above with the profile name and ID of the shared services account configured in aws-vault.

### Setting up your development environment 

1. Copy `.env.example` to `.env`.

```shell
$ cp .env.example .env
```

2. Modify the `.env` file and replace all necessary values.  

3. Now build your development environment by running:
```shell
make build-dev
```

4. Deploy the environment by running:
```shell
make deploy
```

### Running Local Test
To send a test email using your local environment with the email addresses specified in your .ENV file run: 
```shell
make test
```

### Stopping Local Environment

Once you have finished using the docker image run ```make stop``` to shut down the environment.

