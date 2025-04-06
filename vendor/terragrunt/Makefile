export VENDOR ?= gruntwork-io
export DOWNLOAD_URL ?= $(PACKAGE_REPO_URL)/releases/download/v$(PACKAGE_VERSION)/$(PACKAGE_NAME)_$(OS)_$(ARCH)

include ../../includes/vendor.mk

install:
	$(call download_binary)

test:
	$(PACKAGE_EXE) --version
