export VENDOR ?= ethereum
export PACKAGE_REPO_NAME ?= solidity
export DOWNLOAD_URL ?= $(PACKAGE_REPO_URL)/releases/download/v$(PACKAGE_VERSION)/$(PACKAGE_NAME)-static-$(OS)

include ../../includes/vendor.mk

install:
	$(call download_binary)

test:
	$(PACKAGE_EXE) version
