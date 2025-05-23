# macros to download a binary release from GitHub and install it

define download_binary
	mkdir -p -m a+rX $(INSTALL_PATH)
	$(CURL) -o $(INSTALL_PATH)/$(PACKAGE_EXE) $(DOWNLOAD_URL) && chmod +x $(INSTALL_PATH)/$(PACKAGE_EXE)
endef

download/binary:
	$(call download_binary)

define download_binary_gz
	mkdir -p -m a+rX $(INSTALL_PATH)
	$(CURL) -o $(INSTALL_PATH)/$(PACKAGE_NAME).gz $(DOWNLOAD_URL)
	gunzip -f -k -q $(INSTALL_PATH)/$(PACKAGE_NAME).gz
	chmod +x $(INSTALL_PATH)/$(PACKAGE_EXE)
	rm -f $(INSTALL_PATH)/$(PACKAGE_NAME).gz
endef

download/binary/gz:
	$(call download_binary_gz)

define download_binary_bz2
	mkdir -p -m a+rX $(INSTALL_PATH)
	$(CURL) -o $(INSTALL_PATH)/$(PACKAGE_NAME).bz2 $(DOWNLOAD_URL)
	bzip2 -d -f -k -q $(INSTALL_PATH)/$(PACKAGE_NAME).bz2
	chmod +x $(INSTALL_PATH)/$(PACKAGE_EXE)
	rm -f $(INSTALL_PATH)/$(PACKAGE_NAME).bz2
endef

download/binary/bz2:
	$(call download_binary_bz2)

define download_tarball
	mkdir -p -m a+rX $(INSTALL_PATH)
	[ -n "$(TMP)" ] && [ -n "$(PACKAGE_NAME)" ] && rm -rf "$(TMP)/$(PACKAGE_NAME)"
	mkdir -p $(TMP)/$(PACKAGE_NAME)
	$(CURL) -o - $(DOWNLOAD_URL) | tar -zx -C '$(TMP)/$(PACKAGE_NAME)'
	find $(TMP)/$(PACKAGE_NAME) -type f -name '$(PACKAGE_EXE)*' | xargs -I {} cp -f {} $(INSTALL_PATH)/$(PACKAGE_EXE)
	chmod +x $(INSTALL_PATH)/$(PACKAGE_EXE)
	[ -n "$(TMP)" ] && [ -n "$(PACKAGE_NAME)" ] && rm -rf "$(TMP)/$(PACKAGE_NAME)"
endef

download/tarball:
	$(call download_tarball)

define download_tar_bz2
	mkdir -p -m a+rX $(INSTALL_PATH)
	[ -n "$(TMP)" ] && [ -n "$(PACKAGE_NAME)" ] && rm -rf "$(TMP)/$(PACKAGE_NAME)"
	mkdir -p $(TMP)/$(PACKAGE_NAME)
	$(CURL) -o - $(DOWNLOAD_URL) | tar -jx -C $(TMP)/$(PACKAGE_NAME)
	find $(TMP)/$(PACKAGE_NAME) -type f -name $(PACKAGE_NAME) | xargs -I {} cp -f {} $(INSTALL_PATH)/$(PACKAGE_EXE)
	chmod +x $(INSTALL_PATH)/$(PACKAGE_EXE)
	[ -n "$(TMP)" ] && [ -n "$(PACKAGE_NAME)" ] && rm -rf "$(TMP)/$(PACKAGE_NAME)"
endef

download/tar/bz2:
	$(call download_tar_bz2)

define download_tar_gz
	mkdir -p -m a+rX $(INSTALL_PATH)
	[ -n "$(TMP)" ] && [ -n "$(PACKAGE_NAME)" ] && rm -rf "$(TMP)/$(PACKAGE_NAME)"
	mkdir -p $(TMP)/$(PACKAGE_NAME)
	$(CURL) -o - $(DOWNLOAD_URL) | tar -zx -C $(TMP)/$(PACKAGE_NAME)
	find $(TMP)/$(PACKAGE_NAME) -type f -name $(PACKAGE_NAME) | xargs -I {} cp -f {} $(INSTALL_PATH)/$(PACKAGE_EXE)
	chmod +x $(INSTALL_PATH)/$(PACKAGE_EXE)
	[ -n "$(TMP)" ] && [ -n "$(PACKAGE_NAME)" ] && rm -rf "$(TMP)/$(PACKAGE_NAME)"
endef

download/tar/gz:
	$(call download_tar_gz)

define download_tar_xz
	mkdir -p -m a+rX $(INSTALL_PATH)
	[ -n "$(TMP)" ] && [ -n "$(PACKAGE_NAME)" ] && rm -rf "$(TMP)/$(PACKAGE_NAME)"
	mkdir -p $(TMP)/$(PACKAGE_NAME)
	$(CURL) -o - $(DOWNLOAD_URL) | tar -Jx -C $(TMP)/$(PACKAGE_NAME)
	find $(TMP)/$(PACKAGE_NAME) -type f -name $(PACKAGE_NAME) | xargs -I {} cp -f {} $(INSTALL_PATH)/$(PACKAGE_EXE)
	chmod +x $(INSTALL_PATH)/$(PACKAGE_EXE)
	[ -n "$(TMP)" ] && [ -n "$(PACKAGE_NAME)" ] && rm -rf "$(TMP)/$(PACKAGE_NAME)"
endef

download/tar/xz:
	$(call download_tar_xz)

define download_zip
	mkdir -p -m a+rX $(INSTALL_PATH)
	[ -n "$(TMP)" ] && [ -n "$(PACKAGE_NAME)" ] && rm -rf "$(TMP)/$(PACKAGE_NAME)"
	mkdir -p $(TMP)/$(PACKAGE_NAME)
	$(CURL) -L -o $(TMP)/$(PACKAGE_NAME)/$(PACKAGE_NAME).zip $(DOWNLOAD_URL)
	unzip $(TMP)/$(PACKAGE_NAME)/$(PACKAGE_NAME).zip -d $(TMP)/$(PACKAGE_NAME)
	find $(TMP)/$(PACKAGE_NAME) -type f -name $(PACKAGE_NAME) | xargs -I {} cp -f {} $(INSTALL_PATH)/$(PACKAGE_EXE)
	chmod +x $(INSTALL_PATH)/$(PACKAGE_EXE)
	[ -n "$(TMP)" ] && [ -n "$(PACKAGE_NAME)" ] && rm -rf "$(TMP)/$(PACKAGE_NAME)"
endef

download/zip:
	$(call download_zip)

define download_gz
	mkdir -p -m a+rX $(INSTALL_PATH)
	[ -n "$(TMP)" ] && [ -n "$(PACKAGE_NAME)" ] && rm -rf "$(TMP)/$(PACKAGE_NAME)"
	mkdir -p $(TMP)/$(PACKAGE_NAME)
	$(CURL) -L -o $(TMP)/$(PACKAGE_NAME)/$(PACKAGE_NAME).gz $(DOWNLOAD_URL)
	gunzip $(TMP)/$(PACKAGE_NAME)/$(PACKAGE_NAME).gz
	find $(TMP)/$(PACKAGE_NAME) -type f -name $(PACKAGE_NAME) | xargs -I {} cp -f {} $(INSTALL_PATH)/$(PACKAGE_EXE)
	chmod +x $(INSTALL_PATH)/$(PACKAGE_EXE)
	[ -n "$(TMP)" ] && [ -n "$(PACKAGE_NAME)" ] && rm -rf "$(TMP)/$(PACKAGE_NAME)"
endef

download/gz:
	$(call download_gz)
