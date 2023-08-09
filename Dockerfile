ARG BASE_IMAGE=zedalaye/asdf-debian-buster
FROM ${BASE_IMAGE}:latest

ADD ruby .asdf/toolset/ruby/
ADD nodejs .asdf/toolset/nodejs/
ADD yarn .asdf/toolset/yarn/

USER root
RUN  bash .asdf/toolset/ruby/build-deps
RUN  bash .asdf/toolset/nodejs/build-deps
RUN  bash .asdf/toolset/yarn/build-deps

USER asdf
RUN  asdf-install-toolset ruby
RUN  asdf-install-toolset nodejs
RUN  asdf-install-toolset yarn

# Stolen from official Docker Ruby Image
# https://github.com/docker-library/ruby/
USER root
ENV GEM_HOME /usr/local/bundle
ENV BUNDLE_SILENCE_ROOT_WARNING=1 \
	BUNDLE_APP_CONFIG="$GEM_HOME"
ENV PATH $GEM_HOME/bin:$PATH
RUN mkdir -p "$GEM_HOME" && chmod 1777 "$GEM_HOME"

USER asdf
