SHELL := /bin/bash

.PHONY:

ID=docker-build

docker-build:
	docker build \
	--file "Dockerfile" \
	-t "docker.videxio.net/${ID}" .

docker-upload:
	docker push "docker.videxio.net/${ID}"
