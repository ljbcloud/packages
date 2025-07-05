ARG PYTHON_VERSION="3.13.5"

FROM docker.io/library/python:${PYTHON_VERSION}-alpine as build

# hadolint ignore=DL3018
RUN apk add --update --no-cache bash coreutils curl git tar xz

COPY . /packages

WORKDIR /packages

RUN pip install --no-cache-dir uv=="$(awk '/^uv/ {print $2}' .tool-versions)" && \
    uv venv

# hadolint ignore=DL3059
RUN uv run invoke install.all

WORKDIR /packages/dist

FROM scratch

COPY --from=build /packages/dist /dist
