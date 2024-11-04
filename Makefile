#!make
.DEFAULT_GOAL := help
SHELL := '/bin/bash'

CURRENT_TIME := `date "+%Y.%m.%d-%H.%M.%S"`

LOCAL_IMAGE := ministryofjustice/nvvs/terraforms:latest
DOCKER_IMAGE := ghcr.io/ministryofjustice/nvvs/terraforms:latest

DOCKER_RUN := @docker run --rm -it \
				--env-file <(aws-vault exec $$AWS_PROFILE -- env | grep ^AWS_) \
				-v `pwd`:/data \
				--workdir /data \
				--platform linux/amd64 \
				$(DOCKER_IMAGE)

export DOCKER_DEFAULT_PLATFORM=linux/amd64

-include .env
export

.DEFAULT_GOAL := help

DOCKER_COMPOSE = docker-compose -f docker-compose.yml

.PHONY: authenticate-docker
authenticate-docker: ## Authenticate docker using ssm paramstore
	./scripts/authenticate_docker.sh

.PHONY: build-dev
build-dev:## Build dev image
	$(DOCKER_COMPOSE) build

.PHONY: run
run: ## Build dev container and start smtp relay server container
	$(MAKE) build-dev
	$(DOCKER_COMPOSE) up -d smtp_relay_server

.PHONY: test
test: ## Build dev container, start smtp relay server container, run tests
	$(MAKE) run
	$(DOCKER_COMPOSE) up -d smtp_relay_test
	$(DOCKER_COMPOSE) logs smtp_relay_test

.PHONY: test-shell
test-shell: ## shell into test container
	$(MAKE) run
	$(DOCKER_COMPOSE) run --rm smtp_relay_test sh

.PHONY: build
build: ## Docker build smtp-relay container
	docker build --platform=linux/amd64 -t docker_smtp_relay ./smtp-relay

.PHONY: build-nginx
build-nginx: ## Docker build nginx container
	docker build --platform=linux/amd64 -t nginx ./nginx

.PHONY: build-postfix-exporter
build-postfix-exporter: ## Docker build postfix-exporter(smtp relay monitoring) container
	docker build --platform=linux/amd64 -t docker_smtp_relay_monitoring ./smtp-relay-monitoring

.PHONY: push
push: ## Docker tag SMTP relay server container image with latest and push to ECR
	echo ${REGISTRY_URL}
	aws ecr get-login-password | docker login --username AWS --password-stdin ${REGISTRY_URL}
	docker tag docker_smtp_relay:latest ${REGISTRY_URL}/staff-infrastructure-${ENV}-smtp-relay:latest
	docker push ${REGISTRY_URL}/staff-infrastructure-${ENV}-smtp-relay:latest

.PHONY: push-nginx
push-nginx: ## Docker tag smtp-relay-nginx container image with latest and push to ECR
	aws ecr get-login-password | docker login --username AWS --password-stdin ${REGISTRY_URL}
	docker tag nginx:latest ${REGISTRY_URL}/staff-infrastructure-${ENV}-smtp-relay-nginx:latest
	docker push ${REGISTRY_URL}/staff-infrastructure-${ENV}-smtp-relay-nginx:latest

.PHONY: push-postfix-exporter
push-postfix-exporter: ## Docker tag postfix-exporter(smtp relay monitoring) container image with latest and push to ECR
	echo ${REGISTRY_URL}
	aws ecr get-login-password | docker login --username AWS --password-stdin ${REGISTRY_URL}
	docker tag docker_smtp_relay_monitoring:latest ${REGISTRY_URL}/staff-infrastructure-${ENV}-smtp-relay-monitoring:latest
	docker push ${REGISTRY_URL}/staff-infrastructure-${ENV}-smtp-relay-monitoring:latest

.PHONY: publish
publish: ## Build docker image, tag and push  smtp relay:latest, build nginx and postfix-exporter(smtp relay monitoring) image, tag with latest and push
	$(MAKE) build
	$(MAKE) push
	$(MAKE) build-nginx
	$(MAKE) push-nginx
	$(MAKE) build-postfix-exporter
	$(MAKE) push-postfix-exporter

.PHONY: deploy
deploy: ## deploy - zero downtime phased deployment in ECS
	aws-vault exec $$AWS_VAULT_PROFILE --no-session -- ./scripts/deploy.sh

.PHONY: stop
stop: ## stop
	$(DOCKER_COMPOSE) down -v

.PHONY: clean
clean: ## clean env file
	rm -rf .env

.PHONY: gen-env
gen-env: ## generate a ".env" file with the correct env vars for the environment e.g. (make gen-env ENV_ARGUMENT=pre-production)
	$(DOCKER_RUN) /bin/bash -c "./scripts/generate-env-file.sh $$ENV_ARGUMENT"

help:
	@grep -h -E '^[a-zA-Z0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
