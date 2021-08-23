-include .env
export

DOCKER_COMPOSE = docker-compose -f docker-compose.yml

authenticate-docker:
	./scripts/authenticate_docker.sh
	
check-container-registry-account-id:
	./scripts/check_container_registry_account_id.sh

build-dev:
	$(DOCKER_COMPOSE) build

run: build-dev
	$(DOCKER_COMPOSE) up -d smtp_relay_server

test: run
	$(DOCKER_COMPOSE) up -d smtp_relay_test

build: check-container-registry-account-id
	docker build -t docker_smtp_relay ./smtp-relay --build-arg SHARED_SERVICES_ACCOUNT_ID

build-nginx:
	docker build -t nginx ./nginx --build-arg SHARED_SERVICES_ACCOUNT_ID

push:
	echo ${REGISTRY_URL}
	aws ecr get-login-password | docker login --username AWS --password-stdin ${REGISTRY_URL}
	docker tag docker_smtp_relay:latest ${REGISTRY_URL}/staff-infrastructure-${ENV}-smtp-relay:latest
	docker push ${REGISTRY_URL}/staff-infrastructure-${ENV}-smtp-relay:latest

push-nginx:
	aws ecr get-login-password | docker login --username AWS --password-stdin ${REGISTRY_URL}
	docker tag nginx:latest ${REGISTRY_URL}/staff-infrastructure-${ENV}-smtp-relay-nginx:latest
	docker push ${REGISTRY_URL}/staff-infrastructure-${ENV}-smtp-relay-nginx:latest

publish: build push build-nginx push-nginx

deploy:
	aws-vault exec $$AWS_VAULT_PROFILE --no-session -- ./scripts/deploy.sh

stop:
	$(DOCKER_COMPOSE) down -v