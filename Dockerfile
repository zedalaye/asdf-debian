ARG DEBIAN_VERSION=buster-slim
FROM debian:${DEBIAN_VERSION}

LABEL maintainer="Pierre Yager <pierre.y@gmail.com>"
LABEL updated_at=2023-08-06

RUN apt-get update -q && apt-get install -y git curl

RUN adduser --shell /bin/bash --home /asdf --disabled-password asdf
ENV PATH $PATH:/asdf/.asdf/shims:/asdf/.asdf/bin

USER asdf
WORKDIR /asdf

COPY asdf-install-toolset /usr/local/bin

ONBUILD USER asdf
ONBUILD RUN git clone --depth 1 https://github.com/asdf-vm/asdf.git $HOME/.asdf \
  && mkdir -p $HOME/.asdf/toolset \
  && echo '. $HOME/.asdf/asdf.sh' >> ~/.bashrc \
  && echo '. $HOME/.asdf/asdf.sh' >> ~/.profile \
  && . ~/.bashrc
