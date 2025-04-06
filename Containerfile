FROM docker.io/library/alpine:3.20

# hadolint ignore=DL3018
RUN apk add --update --no-cache bash coreutils curl jq make sudo tar xz

COPY . /packages

RUN make -C /packages/install all && \
    make -C /packages dist

WORKDIR /packages/dist
