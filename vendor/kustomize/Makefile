export VENDOR ?= kubernetes-sigs
export DOWNLOAD_URL ?= $(PACKAGE_REPO_URL)/releases/download/kustomize/v$(PACKAGE_VERSION)/$(PACKAGE_NAME)_v$(PACKAGE_VERSION)_$(OS)_$(ARCH).tar.gz

include ../../includes/vendor.mk

install:
	$(call download_tar_gz)

test:
	$(PACKAGE_EXE) version
