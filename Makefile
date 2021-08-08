SHELL := /bin/bash

.PHONY:

ID=build

docker-build:
	docker build \
	--file "Dockerfile" \
	-t "docker.videxio.net/${ID}" .

docker-upload:
	docker push "docker.videxio.net/${ID}"
