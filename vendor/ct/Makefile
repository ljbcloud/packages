export VENDOR ?= helm
export PACKAGE_REPO_NAME ?= chart-testing

include ../../includes/vendor.mk

export DOWNLOAD_URL ?= $(PACKAGE_REPO_URL)/releases/download/v$(PACKAGE_VERSION)/$(PACKAGE_REPO_NAME)_$(PACKAGE_VERSION)_$(OS)_$(ARCH).tar.gz

install:
	$(call download_tar_gz)

test:
	$(PACKAGE_EXE) version
