export VENDOR ?= bitnami-labs
export PACKAGE_REPO_NAME ?= sealed-secrets
export DOWNLOAD_URL ?= $(PACKAGE_REPO_URL)/releases/download/v$(PACKAGE_VERSION)/$(PACKAGE_NAME)-$(PACKAGE_VERSION)-$(OS)-$(ARCH).tar.gz

include ../../includes/vendor.mk

install:
	$(call download_tar_gz)

test:
	$(PACKAGE_EXE) version
