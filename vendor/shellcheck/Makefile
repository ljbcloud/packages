export VENDOR ?= koalaman
export DOWNLOAD_URL ?= $(PACKAGE_REPO_URL)/releases/download/v$(PACKAGE_VERSION)/$(PACKAGE_NAME)-v$(PACKAGE_VERSION).$(OS).$(DL_ARCH).tar.xz

# shellcheck has releases called "stable" and "latest" but they are very old, so ignore them
export PACKAGE_VERSION_SEMVER_XFORM = sed -E 's/(stable|latest)/0.0.0/g'

include ../../includes/vendor.mk

ifeq ($(OS), darwin)
  DL_ARCH=x86_64
else ifeq ($(ARCH), amd64)
  DL_ARCH=x86_64
else ifeq ($(ARCH), arm64)
  DL_ARCH=aarch64
endif

install:
	$(call download_tar_xz)

test:
	$(PACKAGE_EXE) --version | grep -F $(PACKAGE_VERSION)

package/prepare::
	mv src/shellcheck-v$(PACKAGE_VERSION)/shellcheck src
