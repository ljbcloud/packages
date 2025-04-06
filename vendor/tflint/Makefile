export VENDOR ?= terraform-linters
export DOWNLOAD_URL ?= $(PACKAGE_REPO_URL)/releases/download/v$(PACKAGE_VERSION)/$(PACKAGE_NAME)_$(OS)_$(ARCH).zip

include ../../includes/vendor.mk

install:
	$(call download_zip)

test:
	$(PACKAGE_EXE) --version | grep -F $(PACKAGE_VERSION)
