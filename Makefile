ifneq (,)
.error This Makefile requires GNU Make.
endif

.PHONY: build-images printenv push-images run

DOCKER_REPO_HOST ?= ghcr.io
DOCKER_REPO_ORG ?= oscal-club
DOCKER_REPO_PROJ ?= website
DOCKERFILE_JEKYLL ?= Dockerfile-jekyll
DOCKERFILE_IMAGEMAGICK ?= Dockerfile-imagemagick
DOCKERFILE_INKSCAPE ?= Dockerfile-inkscape
JEKYLL_BUILD_COMMAND ?= "bundle install; bundle exec jekyll build"
JEKYLL_PORT ?= 4000
JEKYLL_RUN_COMMAND ?= "bundle install; bundle exec jekyll serve --host=0.0.0.0"
JEKYLL_VERSION ?= 0.0.1
IMAGEMAGICK_VERSION ?= 6.9.6.8-r0
INKSCAPE_VERSION ?= 1.0.2-r75-1-ubuntu20.04.1
WORKDIR ?= $(dir $(abspath $(lastword $(MAKEFILE_LIST))))

build-images:
	docker build \
		-t ${DOCKER_REPO_HOST}/${DOCKER_REPO_ORG}/${DOCKER_REPO_PROJ}/imagemagick:${IMAGEMAGICK_VERSION} \
		-t ${DOCKER_REPO_HOST}/${DOCKER_REPO_ORG}/${DOCKER_REPO_PROJ}/imagemagick:latest \
		-f ${DOCKERFILE_IMAGEMAGICK} \
		${WORKDIR}

	docker build \
		-t ${DOCKER_REPO_HOST}/${DOCKER_REPO_ORG}/${DOCKER_REPO_PROJ}/inkscape:${INKSCAPE_VERSION} \
		-t ${DOCKER_REPO_HOST}/${DOCKER_REPO_ORG}/${DOCKER_REPO_PROJ}/inkscape:latest \
		-f ${DOCKERFILE_INKSCAPE} \
		${WORKDIR}

	docker build \
		-t ${DOCKER_REPO_HOST}/${DOCKER_REPO_ORG}/${DOCKER_REPO_PROJ}/jekyll-site-builder:${JEKYLL_VERSION} \
		-t ${DOCKER_REPO_HOST}/${DOCKER_REPO_ORG}/${DOCKER_REPO_PROJ}/jekyll-site-builder:latest \
		-f ${DOCKERFILE_JEKYLL} \
		${WORKDIR}

build-site:
	docker run \
		-p ${JEKYLL_PORT}:${JEKYLL_PORT}/tcp \
		-v ${WORKDIR}:/srv/jekyll \
		-it \
		--rm \
		--name jekyll-site-builder \
		${DOCKER_REPO_HOST}/${DOCKER_REPO_ORG}/${DOCKER_REPO_PROJ}/jekyll-site-builder:latest \
		/bin/sh -c ${JEKYLL_BUILD_COMMAND}

printenv:
	@echo WORKDIR=${WORKDIR}
	@echo JEKYLL_RUN_COMMAND=${JEKYLL_RUN_COMMAND}
	@echo JEKYLL_PORT=${JEKYLL_PORT}
	@echo DOCKER_REPO_HOST=${DOCKER_REPO_HOST}
	@echo DOCKER_REPO_ORG=${DOCKER_REPO_ORG}
	@echo DOCKER_REPO_PROJ=${DOCKER_REPO_PROJ}

push-images:
	docker push ${DOCKER_REPO_HOST}/${DOCKER_REPO_ORG}/${DOCKER_REPO_PROJ}/imagemagick:${IMAGEMAGICK_VERSION}
	docker push ${DOCKER_REPO_HOST}/${DOCKER_REPO_ORG}/${DOCKER_REPO_PROJ}/imagemagick:latest
	docker push ${DOCKER_REPO_HOST}/${DOCKER_REPO_ORG}/${DOCKER_REPO_PROJ}/inkscape:${INKSCAPE_VERSION}
	docker push ${DOCKER_REPO_HOST}/${DOCKER_REPO_ORG}/${DOCKER_REPO_PROJ}/inkscape:latest
	docker push ${DOCKER_REPO_HOST}/${DOCKER_REPO_ORG}/${DOCKER_REPO_PROJ}/jekyll-site-builder:${JEKYLL_VERSION}
	docker push ${DOCKER_REPO_HOST}/${DOCKER_REPO_ORG}/${DOCKER_REPO_PROJ}/jekyll-site-builder:latest

run:
	docker run \
		-p ${JEKYLL_PORT}:${JEKYLL_PORT}/tcp \
		-v ${WORKDIR}:/srv/jekyll \
		-it \
		--rm \
		--name jekyll-site-builder \
		${DOCKER_REPO_HOST}/${DOCKER_REPO_ORG}/${DOCKER_REPO_PROJ}/jekyll-site-builder:latest \
		/bin/sh -c ${JEKYLL_RUN_COMMAND}
