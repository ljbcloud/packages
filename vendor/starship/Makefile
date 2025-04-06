export VENDOR ?= starship
export PACKAGE_REPO_NAME ?= starship

include ../../includes/vendor.mk

ifeq ($(OS), darwin)
	DL_ARCH=x86_64
else ifeq ($(ARCH), amd64)
	DL_ARCH=x86_64
else ifeq ($(ARCH), arm64)
	DL_ARCH=aarch64
endif

ifeq ($(OS), darwin)
	DL_OS=Darwin
else ifeq ($(OS), linux)
	DL_OS=Linux
endif

export DOWNLOAD_URL ?= $(PACKAGE_REPO_URL)/releases/download/v$(PACKAGE_VERSION)/$(PACKAGE_REPO_NAME)-$(DL_ARCH)-unknown-$(OS)-gnu.tar.gz

install:
	$(call download_tar_gz)

test:
	$(PACKAGE_EXE) version
