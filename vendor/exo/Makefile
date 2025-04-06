export VENDOR ?= exoscale
export PACKAGE_REPO_NAME ?= cli
export DOWNLOAD_URL ?= $(PACKAGE_REPO_URL)/releases/download/v$(PACKAGE_VERSION)/$(VENDOR)-$(PACKAGE_REPO_NAME)_$(PACKAGE_VERSION)_$(OS)_$(ARCH).tar.gz

include ../../includes/vendor.mk

install:
	$(call download_tar_gz)

test:
	$(PACKAGE_EXE) version
