FROM ubuntu:20.04
ARG DEBIAN_FRONTEND=noninteractive
ARG USER=drift
ARG DOCKER_VERSION=20.10.8
ARG GOLANG_VERSION=1.15.15

WORKDIR /opt

run apt-get update && apt-get install -y \
  ca-certificates \
	iptables \
	wget \
	curl \
	unzip \
	vim \
	ssh \
	git \
	jq \
	sudo \
	git-crypt \
	gcc \
	supervisor \
	go-bindata \
	make

# create user(s)
RUN useradd -ms /bin/bash ${USER} && echo 'drift:drift' | chpasswd
RUN usermod -aG sudo ${USER} && echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
RUN groupadd docker && usermod -aG docker ${USER} && newgrp docker

# golang install
RUN wget -P /tmp https://dl.google.com/go/go${GOLANG_VERSION}.linux-amd64.tar.gz
RUN tar -C /usr/local -xzf /tmp/go${GOLANG_VERSION}.linux-amd64.tar.gz
RUN rm /tmp/go${GOLANG_VERSION}.linux-amd64.tar.gz

ENV GOPATH /go
ENV PATH $GOPATH/bin:/usr/local/go/bin:$PATH
RUN mkdir -p "$GOPATH/src" "$GOPATH/bin" && chmod -R 777 "$GOPATH"

# docker install
RUN set -eux; \
	\
	if ! wget -O docker.tgz "https://download.docker.com/linux/static/stable/x86_64/docker-${DOCKER_VERSION}.tgz"; then \
		echo >&2 "error: failed to download 'docker-${DOCKER_VERSION}'"; \
		exit 1; \
	fi; \
	\
	tar --extract \
		--file docker.tgz \
		--strip-components 1 \
		--directory /usr/local/bin/ \
	; \
	rm docker.tgz; \
	\
	dockerd --version; \
	docker --version

RUN wget -P /etc/ssl/certs https://github.com/pexip/ca-certificates/raw/master/videxio.pem
RUN wget -P /etc/ssl/certs https://github.com/pexip/ca-certificates/raw/master/pravda.pem
RUN sudo update-ca-certificates
COPY ./resources/docker/modprobe ./resources/docker/startup.sh /usr/local/bin/
COPY ./resources/docker/supervisor/ /etc/supervisor/conf.d/
COPY ./resources/docker/logger.sh /opt/bash-utils/logger.sh

RUN chmod +x /usr/local/bin/startup.sh /usr/local/bin/modprobe
VOLUME /var/lib/docker

# configure user env
COPY ./resources/bashrc /home/${USER}/.bashrc
COPY ./resources/bashrc.d /home/${USER}/.bashrc.d
COPY ./resources/ssh/config /home/${USER}/.ssh/config
COPY ./resources/bin/ /usr/local/bin

RUN chown -R ${USER}:${USER} /home/${USER}

USER ${USER}
WORKDIR /home/${USER}

ENTRYPOINT ["startup.sh"]
CMD ["sh"]
