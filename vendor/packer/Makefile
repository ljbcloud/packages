export VENDOR ?= hashicorp
export DOWNLOAD_URL ?= https://releases.hashicorp.com/$(PACKAGE_NAME)/$(PACKAGE_VERSION)/$(PACKAGE_NAME)_$(PACKAGE_VERSION)_$(OS)_$(ARCH).zip

include ../../includes/vendor.mk

install:
	$(call download_zip)

test:
	$(PACKAGE_EXE) --version
