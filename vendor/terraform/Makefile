export VENDOR ?= hashicorp
export PACKAGE_REPO_NAME = terraform
export DOWNLOAD_URL ?= https://releases.hashicorp.com/terraform/$(PACKAGE_VERSION)/terraform_$(PACKAGE_VERSION)_$(OS)_$(ARCH).zip

include ../../includes/vendor.mk

install:
	$(call download_zip)

test:
	$(PACKAGE_EXE) version | grep -F $(PACKAGE_VERSION)
