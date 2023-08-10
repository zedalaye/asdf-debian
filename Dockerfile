ARG DEBIAN_VERSION=buster-slim
FROM debian:${DEBIAN_VERSION}

LABEL maintainer="Pierre Yager <pierre.y@gmail.com>"
LABEL updated_at=2023-08-06

RUN adduser --shell /bin/bash --home /app --disabled-password app
ENV PATH $PATH:/app/.asdf/shims:/app/.asdf/bin
WORKDIR /app

RUN apt-get update -q && apt-get install -y git curl

COPY asdf-install-toolset /usr/local/bin

# Required because we build packages as root and
# we don't want asdf to put packages into /root/.asdf
ONBUILD ENV ASDF_DIR=/app/.asdf \
			ASDF_DATA_DIR=/app/.asdf
ONBUILD RUN git clone --depth 1 https://github.com/asdf-vm/asdf.git ${ASDF_DIR} \
  && mkdir -p ${ASDF_DIR}/toolset \
  && echo '. ${ASDF_DIR}/asdf.sh' >> /app/.bashrc \
  && echo '. ${ASDF_DIR}/asdf.sh' >> /app/.profile \
  && . /app/.bashrc
