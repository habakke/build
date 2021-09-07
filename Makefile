SHELL := /bin/bash

.PHONY:

ID=build

docker-build:
	docker build \
	--file "Dockerfile" \
	-t "ghcr.io/habakke/${ID}" .

docker-upload:
	docker push "ghcr.io/habakke/${ID}"

run:
	sh docker.sh

release:
	git tag -a $(VERSION) -m "Release" && git push origin $(VERSION)
