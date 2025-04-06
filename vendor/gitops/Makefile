export VENDOR ?= weaveworks
export PACKAGE_REPO_NAME ?= weave-gitops

include ../../includes/vendor.mk

ifeq ($(ARCH), amd64)
	DL_ARCH=x86_64
else ifeq ($(ARCH), arm64)
	DL_ARCH=aarch64
endif

ifeq ($(OS), darwin)
	DL_OS=Darwin
else ifeq ($(OS), linux)
	DL_OS=Linux
endif

export DOWNLOAD_URL ?= $(PACKAGE_REPO_URL)/releases/download/v$(PACKAGE_VERSION)/$(PACKAGE_NAME)-$(DL_OS)-$(DL_ARCH).tar.gz

install:
	$(call download_tar_gz)

test:
	$(PACKAGE_EXE) version
