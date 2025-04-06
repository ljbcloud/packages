export VENDOR ?= kubernetes-sigs
export DOWNLOAD_URL ?= $(PACKAGE_REPO_URL)/releases/download/v$(PACKAGE_VERSION)/$(PACKAGE_NAME)-$(OS)-$(ARCH)

include ../../includes/vendor.mk

install:
	$(call download_binary)

test:
	$(PACKAGE_EXE) version
