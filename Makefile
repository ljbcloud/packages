export PACKAGES     ?= $(strip $(foreach pkg,$(shell find vendor/ -type d),$(subst vendor/,,$(pkg))))
export INSTALL_PATH ?= /usr/local/bin
export DIST_PATH    := $(CURDIR)/dist
export DIST_CMD     := cp -a

dist:
	mkdir -p "$(DIST_PATH)"
	[ -z "$(PACKAGES)" ] || \
		(cd "$(INSTALL_PATH)" && $(DIST_CMD) $(PACKAGES) "$(DIST_PATH)")

test:
	echo $(PACKAGES)

.PHONY: build dist test
