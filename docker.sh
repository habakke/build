#!/bin/bash

SCRIPT_PATH="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
REPO_PATH=$(git rev-parse --show-toplevel)
HOME_PATH=$(eval echo ~$USER)
CODE_PATH=$(git rev-parse --show-toplevel)/..

docker run --cap-add CAP_NET_ADMIN --cap-add CAP_SYS_ADMIN -it \
     --mount type=bind,source="${GOPATH}/pkg/mod",target="/go/pkg/mod" \
		 --mount type=cache,target="/home/drift/.cache/go-build" \
	   --mount type=bind,source="${CODE_PATH}",target="/home/drift/code" \
		 --mount type=bind,source="${HOME_PATH}/.docker/config.json",target="/home/drift/.docker/config.json" \
	   --mount type=bind,source="${HOME_PATH}/.ssh/known_hosts",target="/home/drift/.ssh/known_hosts" \
	   --mount type=bind,source="${HOME_PATH}/.ssh/id_ed25519",target="/home/drift/.ssh/id_ed25519" \
	   --mount type=bind,source="${HOME_PATH}/.ssh/id_ed25519-cert.pub",target="/home/drift/.ssh/id_ed25519-cert.pub" \
	   ghcr.io/habakke/build:latest \
	   /bin/bash
