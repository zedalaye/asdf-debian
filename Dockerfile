ARG BASE_IMAGE=zedalaye/asdf-debian-buster
FROM ${BASE_IMAGE}:latest

USER root

ADD ruby ${ASDF_DIR}/toolset/ruby/
ADD nodejs ${ASDF_DIR}/toolset/nodejs/
ADD yarn ${ASDF_DIR}/toolset/yarn/

RUN set -eux; \
	echo ASDF_DIR=${ASDF_DIR} ASDF_DATA_DIR=${ASDF_DATA_DIR}; \
	apt-get update; \
# Manually install these dependencies so they won't be removed
	bash ${ASDF_DIR}/toolset/ruby/runtime-deps; \
    bash ${ASDF_DIR}/toolset/nodejs/runtime-deps; \
    bash ${ASDF_DIR}/toolset/yarn/runtime-deps; \
# Prepare for further cleanup
	savedAptMark="$(apt-mark showmanual)"; \
# Prepare for install
	bash ${ASDF_DIR}/toolset/ruby/build-deps; \
    bash ${ASDF_DIR}/toolset/nodejs/build-deps; \
    bash ${ASDF_DIR}/toolset/yarn/build-deps; \
# Install packages
    RUBY_CONFIGURE_OPTS="--disable-install-doc" asdf-install-toolset ruby; \
    asdf-install-toolset nodejs; \
    asdf-install-toolset yarn; \
# Cleanup : keep only required dependencies
# Stolen from official Docker Ruby Image
# https://github.com/docker-library/ruby/
    apt-mark auto '.*' > /dev/null; \
	apt-mark manual $savedAptMark > /dev/null; \
	find ${ASDF_DIR}/ -type f -executable -not \( -name '*tkinter*' \) -exec ldd '{}' ';' \
		| awk '/=>/ { so = $(NF-1); if (index(so, "/app/.asdf/") == 1) { next }; gsub("^/(usr/)?", "", so); print so }' \
		| grep -v 'not a dynamic executable' \
		| sort -u \
		| xargs -r dpkg-query --search \
		| cut -d: -f1 \
		| sort -u \
		| xargs -r apt-mark manual \
	; \
	apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false; \
# Give /app to app user
	chown -R app:app /app

ENV GEM_HOME /usr/local/bundle
ENV BUNDLE_SILENCE_ROOT_WARNING=1 \
	BUNDLE_APP_CONFIG="$GEM_HOME"
ENV PATH $GEM_HOME/bin:$PATH
RUN mkdir -p "$GEM_HOME" && chmod 1777 "$GEM_HOME"

USER app
