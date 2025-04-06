export VENDOR ?= tmrts
export DOWNLOAD_URL ?= $(PACKAGE_REPO_URL)/releases/download/$(PACKAGE_VERSION)/$(PACKAGE_NAME)-$(PACKAGE_VERSION)-$(OS)_$(ARCH).tgz

include ../../includes/vendor.mk

install:
	$(call download_tar_gz)

test:
	$(PACKAGE_EXE) version
