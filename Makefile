SHELL=/bin/bash

# Project variables
CONTAINER_NAME ?= freshclam-mirror
VERSION ?= $(shell git rev-parse HEAD)
DOCKER_REGISTRY ?= ghcr.io/openclarity
DOCKER_IMAGE ?= $(DOCKER_REGISTRY)/$(CONTAINER_NAME)
DOCKER_TAG ?= ${VERSION}

# HELP
# This will output the help for each task
# thanks to https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
.PHONY: help
help: ## This help.
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.DEFAULT_GOAL := help

.PHONY: docker
docker: ## Build Docker image
	@(echo "Building docker image...")
	docker build --file ./Dockerfile --build-arg VERSION=${VERSION} \
		--build-arg BUILD_TIMESTAMP=$(shell date -u +"%Y-%m-%dT%H:%M:%SZ") \
		--build-arg COMMIT_HASH=$(shell git rev-parse HEAD) \
		-t ${DOCKER_IMAGE}:${DOCKER_TAG} .


.PHONY: push-docker
push-docker: docker ## Build and Push Docker image
	@echo "Publishing docker image..."
	docker push ${DOCKER_IMAGE}:${DOCKER_TAG}
