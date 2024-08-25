FROM ubuntu:22.04

ARG USER=cyf0rk
ARG group=cyf0rk
ARG uid=1000
ARG DEBIAN_FRONTEND=noninteractive

USER ${USER}
USER root

RUN apt-get update && \
  apt-get upgrade -y && \
  apt-get install -y \
  sudo \
  curl \
  git-core \
  gnupg \
  locales \
  tzdata \
  wget && \
  apt-get autoremove -y

RUN locale-gen en_US.UTF-8

RUN adduser --quiet --disabled-password \
  --shell /bin/bash --home /home/${USER} \
  --gecos "User" ${USER}

RUN mkdir -p /etc/sudoers.d && \
  touch /etc/sudoers.d/${USER} && \
  echo "%${group} ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/${USER} && \
  groupadd docker && \
  usermod -aG docker ${USER}

RUN chown -R ${USER}:${group} /home/${USER}
USER ${USER}

COPY --chown=${USER}:${group} bin/dev /home/${USER}/.local/bin/dev

RUN \
  mkdir -p /home/${USER}/.ansible-vault && \
  touch /home/${USER}/.ansible-vault/vault.secret && \
  echo '$vault_secret' > /home/${USER}/.ansible-vault/vault.secret

# RUN bash -c "$(curl -fsSL https://raw.githubusercontent.com/cyf0rk/dev/main/bin/dev)"
RUN git clone --quiet https://github.com/cyf0rk/dev.git /home/${USER}/dev
RUN bash -c "/home/${USER}/.local/bin/dev"

RUN rm ~/.ansible-vault/vault.secret

CMD []

ENTRYPOINT ["/bin/bash"]
