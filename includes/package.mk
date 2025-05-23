# Build Environment

# As a rule, we build packages on the target platform (OS and CPU architecture)
# so that we can test the installation of the packages and verify the executable works.

# This gets the directory of the last Makefile opened, which here is the current one
SELF_DIR := $(dir $(lastword $(MAKEFILE_LIST)))

# Brief tutorial on make variables:
#
# Make variables are recursively defined, meaning any variables on the right hand
# side are evaluated at the time the variable on the left hand side is **referenced**
# not the value at the time it is defined. This is especially handy as variable values
# can change during the course of the make session. For example, the line
#
# target: VAR = target_var
#
# sets the value of $(VAR) to "target_var" only for the portion of the build that
# is building "target". So if DEF = DEF_$(VAR), then $(DEF) will be "DEF_target_var"
# even if elsewhere VAR = global_var.
#
# This feature is how it is possible for us to include this Makefile.package at the
# top of a vendor/*/Makefile and still have the later Makefile influence the recipes
# in this Makefile. The global value of the variable is based on the last assignment.
#
# On the other hand, conditionals like `ifeq` and assignments using ?= depend
# on the value of the variable at the time that line of the Makefile is being
# parsed. If this Makefile.package is at the top of the vendor Makefile, then
# nothing in the vendor Makefile will affect the `ifeq` or ?=. However,
# since **variables get their initial values from the shell environment**
# it is still useful to use ?= at the start of the Makefile.
#
# Note: "?=" means set if unset and will not modify a variable that has been set, even if it is empty.
# To allow a variable that has already been set to be set with ?= you must `undefine` it.

# Note: := means left hand var gets the value of the right hand vars as they are right now.
# Setting HOST_* using := prevents a shell from being spawned every time it is referenced.
# HOST_DISTRIBUTION is the distribution (e.g. alpine, debian, centos) of the running Docker image
export HOST_DISTRIBUTION := $(shell [ -r /etc/os-release ] && . /etc/os-release || ID=darwin; echo $$ID)
# DIST_DISTRIBUTION is the target distribution of the package. Default to host
export DIST_DISTRIBUTION ?= $(HOST_DISTRIBUTION)
# HOST_OS is the OS of the packaging Docker container forced to lower case,
# which is same as Go language's GOOS and Docker's platform.os
export HOST_OS := $(shell uname -s | tr '[:upper:]' '[:lower:'])
# Setting OS = $(HOST_OS) gives us a way to conditionally set OS based on HOST_OS
# while avoiding a recursive OS = $(OS) situation.
# OS is the designation of the target OS as specified by the package source releaser
export OS ?= $(HOST_OS)
# DIST_OS is the designation of the target OS as specified in the package we create
export DIST_OS ?= $(HOST_OS)
# "Native" is whatever uname -m returns. On Macs, it is x86_64 or arm64,
# but on Linux it is x86_64 or aarch64.
export HOST_NATIVE_ARCH := $(shell uname -m)
# Go lang supplies GOARCH which is arm64 for aarch64 and amd64 for x86_64.
# We calculate GOARCH from HOST_NATIVE_ARCH so that we do not depend on having Go installed.
# Debian packages use the same architecture names as GOARCH.
export HOST_GOARCH := $(shell printf "%s" "$${HOST_GOARCH:-$$(uname -m)}" | sed 's/aarch64/arm64/' | sed 's/x86_64/amd64/')
# ARCH is the architecture of the release artifact to download
export ARCH ?= $(HOST_GOARCH)
export OS_ARCH ?= $(HOST_NATIVE_ARCH)
export INSTALL_PATH ?= /usr/local/bin
export CURL ?= curl --retry 3 --retry-delay 5 --fail -sSL
export LOCAL_BIN ?= ../../bin
# If you set "PATH := $(PATH):$(LOCAL_BIN)" and LOCAL_BIN were changed later in the Makefile,
# PATH would still refer to the value above. However, we want PATH to get the "current"
# value of LOCAL_BIN. We cannot use "PATH = $(PATH):$(LOCAL_BIN)" because that would
# cause and infinite loop, as PATH is recursively evaluated. Fortunately, Make has
# a solution for that: "PATH += :$(LOCAL_BIN)", but unfortunately, it does not
# work for PATH, because += inserts a space between the old value and the newly added value.
export PATH := $(PATH):$(LOCAL_BIN)
# SHELL is a special variable that defines the binary Make will use to execute shell commands.
export SHELL := /bin/bash
# .DEFAULT_GOAL is a special variable that defines which make target to use when none is given on the command line
export .DEFAULT_GOAL := default
# TMP is not a special variable
export TMP ?= /tmp

# Package details
export PACKAGE_ENABLED ?= true
export PACKAGE_PRERELEASE_ENABLED ?= false
# Leave PACKAGE_VERSION_PIN unset to use latest version
export PACKAGE_NAME ?= $(notdir $(CURDIR))
export PACKAGE_REPO_NAME ?= $(PACKAGE_NAME)
export PACKAGE_EXE ?= $(PACKAGE_NAME)
export PACKAGE_DESCRIPTION ?= $(shell cat DESCRIPTION 2>/dev/null)
export PACKAGE_VERSION ?= $(shell cat VERSION 2>/dev/null)
export PACKAGE_RELEASE ?= $(shell cat RELEASE 2>/dev/null)
export PACKAGE_LICENSE ?= $(shell cat LICENSE 2>/dev/null)
export PACKAGE_HOMEPAGE_URL ?= https://github.com/$(VENDOR)/$(PACKAGE)
export PACKAGE_REPO_URL ?= https://github.com/$(VENDOR)/$(PACKAGE_REPO_NAME)
export PACKAGE_GOLANG_NAME ?= github.com/$(VENDOR)/$(PACKAGE_REPO_NAME)

export PACKAGE_VERSION_TARGET ?= RELEASE_VERSION

export AUTO_UPDATE_ENABLED ?= true

# Permit version to be overridden on the command line using PACKAGE_VERSION (e.g. terraform_VERSION=0.3.0)
VERSION_ENV = $(PACKAGE_NAME)_VERSION
RELEASE_ENV = $(PACKAGE_NAME)_RELEASE
ifneq ($(strip $($(VERSION_ENV))),)
	PACKAGE_VERSION=$(strip $($(VERSION_ENV)))
	# $() is hack to include leading space in variable assignment
	PACKAGE_VERSION_OVERRIDE = $() (overridden by $(VERSION_ENV) environment variable)
	ifneq ($(strip $($(RELEASE_ENV))),)
    	PACKAGE_RELEASE=$(strip $($(RELEASE_ENV)))
    	# $() is hack to include leading space in variable assignment
    	PACKAGE_RELEASE_OVERRIDE = $() (overridden by $(RELEASE_ENV) environment variable)
    endif
endif

default: info
	@echo
	@echo You probably want to specify a target
	@exit 1

# Only works if current working directory is under vendor/
$(LOCAL_BIN)/vert: INSTALL_PATH = $(LOCAL_BIN)
$(LOCAL_BIN)/vert:
	$(MAKE) -C ../vert install

DESCRIPTION:
	@# Use `tr -d '\"$'` to help guard against malicious input
	@github-repo-metadata $(VENDOR) $(PACKAGE_REPO_NAME) "index" .description | tr -d '\"$$' | tee DESCRIPTION

# In order to support static configuration of version, the VERSION file should be
# considered up-to-date unless explicitly updated via the "update" target
# VERSION:

LICENSE:
	@github-repo-metadata $(VENDOR) $(PACKAGE_REPO_NAME) "license" .license.spdx_id | tr '[:lower:]' '[:upper:]' | tee LICENSE

RELEASE: VERSION LICENSE DESCRIPTION
	@if [ ! -f RELEASE ]; then \
		echo "0" | tee RELEASE; \
		git add RELEASE; \
	elif [ -n "$$(git status -s `pwd` | grep -v RELEASE)" ]; then \
		if [ -n "$$(git status -s `pwd` | grep VERSION)" ]; then \
			echo "0" | tee RELEASE; \
			git add RELEASE; \
		elif [ -z "$$(git status -s `pwd` | grep RELEASE)" ]; then \
			echo "$$(($${RELEASE}+1))" | tee RELEASE; \
			git add RELEASE; \
		fi; \
	fi

init: AUTO_UPDATE_ENABLED=true
init: LICENSE DESCRIPTION $(PACKAGE_VERSION_TARGET) RELEASE

update: $(PACKAGE_VERSION_TARGET) RELEASE

force-update: AUTO_UPDATE_ENABLED=true
force-update: $(PACKAGE_VERSION_TARGET) RELEASE

sleep: RATE_LIMIT=0
sleep:
	sleep $(RATE_LIMIT)

auto-update:
	@if [ "$${AUTO_UPDATE_ENABLED:-true}" == "true" ]; then \
		$(MAKE) --quiet --silent --no-print-directory update; \
		exit $?; \
	elif [ "$${AUTO_UPDATE_ENABLED}" == "softfail" ]; then \
		$(MAKE) --quiet --silent --no-print-directory update || \
			printf "\n^^^Automatic updates allowed to fail for %s^^^\n\n" "$${PACKAGE_NAME}"; \
		exit 0; \
	else \
		echo "Automatic updates disabled for $${PACKAGE_NAME}"; \
		exit 0; \
	fi

# The only way to tell if VERSION is up to date is to query the source via the internet
.PHONY: TAGGED_VERSION RELEASE_VERSION

# Update the VERSION file according to the release version.
RELEASE_VERSION: API=releases?per_page=100
RELEASE_VERSION: QUERY=.[] | select(.prerelease == false or .prerelease == $(PACKAGE_PRERELEASE_ENABLED)) | .tag_name
RELEASE_VERSION: _version_by_semver

# Update the VERSION file according to the tags.
TAGGED_VERSION: API=tags?per_page=100
TAGGED_VERSION: QUERY=.[] | .name
TAGGED_VERSION: _version_by_semver

# These lines implement the following logic to determine TARGET_VERSION_PIN
# If PACKAGE_VERSION_PIN is set, then use it
# else if MAJOR_VERSION is set and is not "latest",
#    use $(MAJOR_VERSION).x-0 if PACKAGE_PRERELEASE_ENABLED is set and is not "false"
#    otherwise use $(MAJOR_VERSION).x
# else leave it blank, because we want the  recipe to put the current version in the pin
# to make the real default pin which is >=current-version.
_version_by_semver: TARGET_MAJOR_VERSION = $(strip $(subst latest,,$(MAJOR_VERSION)))
_version_by_semver: DEFAULT_PIN_SUFFIX = $(if $(subst false,,$(PACKAGE_PRERELEASE_ENABLED)),-0,)
_version_by_semver: DEFAULT_PIN_PREFIX = $(if $(TARGET_MAJOR_VERSION),=,>=)
_version_by_semver: DEFAULT_VERSION_PIN = $(if $(TARGET_MAJOR_VERSION),$(TARGET_MAJOR_VERSION).x$(DEFAULT_PIN_SUFFIX))
_version_by_semver: TARGET_VERSION_PIN = $(or $(PACKAGE_VERSION_PIN),$(DEFAULT_VERSION_PIN))
# Not all packages actually use semver. Packages can provide a shell snippet to transform the package's
# release version format into something semver compliant.
_version_by_semver: VERSION_XFORM = $(if $(PACKAGE_VERSION_SEMVER_XFORM), | $(PACKAGE_VERSION_SEMVER_XFORM))
_version_by_semver: $(LOCAL_BIN)/vert
	@if [[ "$${AUTO_UPDATE_ENABLED:-true}" == "true" ]] || [[ "$${AUTO_UPDATE_ENABLED}" == "softfail" ]]; then \
		local_version=$$(cat VERSION || echo 0); version_pin='$(TARGET_VERSION_PIN)'; \
		version_pin="$${version_pin:-$(DEFAULT_PIN_PREFIX)$$local_version$(DEFAULT_PIN_SUFFIX)}"; \
		releases=($$(env PATH='$(PATH)' github-repo-metadata $(VENDOR) $(PACKAGE_REPO_NAME) '$(API)' '$(QUERY)'$(VERSION_XFORM))); \
		current_version=$$(env PATH='$(PATH)' vert -s "$${version_pin}" "$${releases[@]}" | tail -1); \
		if [ $$? -ne 0 ]; then \
			exit 1; \
		elif [ "$${current_version}" == "null" -o -z "$${current_version}" ]; then \
			echo "ERROR: failed to obtain version matching '$${version_pin}' for $(VENDOR)/$(PACKAGE_REPO_NAME) (got: $${releases[@]:0:10}...)" >&2; \
			exit 1; \
		elif [ "$${local_version}" != "$${current_version}" ]; then \
			if ! env PATH='$(PATH)' vert ">$${local_version}$(DEFAULT_PIN_SUFFIX)" "$${current_version}" >/dev/null; then \
				echo "NOT \"Upgrading\" $(PACKAGE_NAME) from $${local_version} to OLDER $${current_version}" >&2; \
				exit 1; \
			else \
				echo "Upgrading $(PACKAGE_NAME) from $${local_version} to $${current_version}"; \
				echo "$${current_version}" > VERSION; \
			fi; \
		fi; \
	else \
		echo "NOT \"Upgrading\" $(PACKAGE_NAME) from $${local_version} to $${current_version} because auto-update is disabled" >&2; \
	fi

# Latest GitHub Release, for packages that do not use anything like semver
GITHUB_LATEST_RELEASE: API=releases?per_page=100
GITHUB_LATEST_RELEASE: QUERY=.[] | select(.prerelease == false or .prerelease == $(PACKAGE_PRERELEASE_ENABLED)) | .tag_name
GITHUB_LATEST_RELEASE:
	@if [[ "$${AUTO_UPDATE_ENABLED:-true}" == "true" ]] || [[ "$${AUTO_UPDATE_ENABLED:-true}" == "softfail" ]]; then \
		local_version=$$(cat VERSION || echo 0); \
		releases=($$(env PATH='$(PATH)' github-repo-metadata $(VENDOR) $(PACKAGE_REPO_NAME) '$(API)' '$(QUERY)')); \
		current_version="$${releases[0]}"; \
		if [ $$? -ne 0 ]; then \
			exit 1; \
		elif [ "$${current_version}" == "null" -o -z "$${current_version}" ]; then \
			echo "ERROR: failed to obtain version matching '$${version_pin}' for $(VENDOR)/$(PACKAGE_REPO_NAME) (got: $${releases[@]:0:10}...)" >&2; \
			exit 1; \
		elif [ "$${local_version}" != "$${current_version}" ]; then \
			echo "Upgrading $(PACKAGE_NAME) from $${local_version} to $${current_version}"; \
			echo "$${current_version}" > VERSION; \
		fi; \
	else \
		echo "NOT \"Upgrading\" $(PACKAGE_NAME) from $${local_version} to $${current_version} because auto-update is disabled" >&2; \
	fi

GOLANG_LATEST_VERSION:
	go get -u $(PACKAGE_GOLANG_NAME)
	printf "%s" $$(grep -F $(PACKAGE_GOLANG_NAME) go.mod| sed -e 's/.* v//' -e 's/\.0-/./' -e 's/-/+git/') > VERSION

.PHONY: info info/short info/github info/md

info:
	@printf "%-20s %s\n" "Vendor:" "$(VENDOR)"
	@printf "%-20s %s\n" "Package:" "$(PACKAGE_NAME)"
	@if [[ $${PACKAGE_ENABLED:-true} != "false" ]]; then \
		printf "%-20s %s\n" "Version:" "$(PACKAGE_VERSION)$${package_version_star}$(PACKAGE_VERSION_OVERRIDE)"; \
	else \
		printf "%-20s %s\n" "Version:" "OBSOLETE"; \
	fi
	@printf "%-20s %s\n" "License:" "$(PACKAGE_LICENSE)"
	@if [[ "$(PACKAGE_ARCHS_DISABLED)" =~ "$(HOST_GOARCH)" ]]; then \
		package_arch_disabled=' (DISABLED)'; \
	fi; \
	printf "%-20s %s\n" "Arch:" "$(if $(subst rhel,,$(DIST_DISTRIBUTION)),$(HOST_GOARCH),$(HOST_NATIVE_ARCH))$${package_arch_disabled}"
	@printf "%-20s %s\n" "OS:" "$(DIST_OS)"
	@printf "%-20s %s\n" "Distribution:" "$(DIST_DISTRIBUTION)"
	@printf "%-20s %s\n" "Homepage URL:" "$(PACKAGE_HOMEPAGE_URL)"
	@printf "%-20s %s\n" "Repo URL:" "$(PACKAGE_REPO_URL)"
	@printf "%-20s %s\n" "Download URL:" "$(DOWNLOAD_URL)"
	@printf "%-20s %s\n" "Install Path:" "$(INSTALL_PATH)"

# info/short is used to make docs/targets.md
info/short:
	@if [[ $${PACKAGE_ENABLED:-true} != "false" ]]; then \
		if [[ "$(PACKAGE_ARCHS_DISABLED)" != "" ]]; then \
    		package_arch_incomplete='*'; \
    	fi; \
		printf "%-25s %-10s %s\n" "$${PACKAGE_NAME}$${package_arch_incomplete}" "$${PACKAGE_VERSION}" "$${PACKAGE_DESCRIPTION}"; \
	else \
		printf "%-25s %-10s %s\n" "$${PACKAGE_NAME}" "OBSOLETE" "$${PACKAGE_DESCRIPTION}"; \
	fi

# info/md is used to make docs/badges.md
info/md:
	@if [[ $${PACKAGE_ENABLED:-true} != "false" ]]; then \
		printf "[![%s](https://github.com/cloudposse/packages/workflows/%s/badge.svg?branch=master)](https://github.com/cloudposse/packages/actions?query=workflow%%3A%s) | %-10s | %s\n" "$${PACKAGE_NAME}" "$${PACKAGE_NAME}" "$${PACKAGE_NAME}" "$${PACKAGE_VERSION}" "$${PACKAGE_DESCRIPTION}"; \
	fi

# info/github is used to configure GitHub Actions, particularly build and auto-update
info/github: FORMAT="%s=%s\n"
info/github:
	@printf $(FORMAT) "vendor" "$(VENDOR)"  >> $$GITHUB_OUTPUT
	@printf $(FORMAT) "package_name" "$(PACKAGE_NAME)"  >> $$GITHUB_OUTPUT
	@$(LOCAL_BIN)/package-filter info/github "$(APK_PACKAGE_ENABLED)" "$(PACKAGE_TYPES_DISABLED)" >> $$GITHUB_OUTPUT
	@printf $(FORMAT) "package_enabled" "$(PACKAGE_ENABLED)"  >> $$GITHUB_OUTPUT
	@printf $(FORMAT) "package_version" "$(PACKAGE_VERSION)"  >> $$GITHUB_OUTPUT
	@printf $(FORMAT) "package_license" "$(PACKAGE_LICENSE)"  >> $$GITHUB_OUTPUT
	@$(LOCAL_BIN)/arch-filter info/github "$(PACKAGE_ARCHS_DISABLED)" >> $$GITHUB_OUTPUT
	@# @printf $(FORMAT) "os" "$(DIST_OS)"  >> $$GITHUB_OUTPUT
	@printf $(FORMAT) "package_homepage_url" "$(PACKAGE_HOMEPAGE_URL)"  >> $$GITHUB_OUTPUT
	@printf $(FORMAT) "package_repo_url" "$(PACKAGE_REPO_URL)"  >> $$GITHUB_OUTPUT
	@printf $(FORMAT) "download_url" "$(DOWNLOAD_URL)"  >> $$GITHUB_OUTPUT
	@printf $(FORMAT) "install_path" "$(INSTALL_PATH)"  >> $$GITHUB_OUTPUT

# info/package-enabled outputs "true" if the package is enabled, "false" if it is not.
# Used by scripts and other info targets to toggle behaviors such as creating or not creating a build action workflow.
info/package-enabled:
	@status="$${PACKAGE_ENABLED:-true}"; echo "$${status}"

info/arch-enabled:
	@$(LOCAL_BIN)/arch-filter arch-enabled "$(HOST_GOARCH)" "$(PACKAGE_ARCHS_DISABLED)"

# info/auto-update-enabled outputs "true" if auto-updates for the package are enabled, "false" if they are not.
# Used by scripts and other info targets to toggle behaviors such as creating or not creating an update workflow.
info/auto-update-enabled:
	@status="$${PACKAGE_ENABLED:-true}"; auto="$${AUTO_UPDATE_ENABLED}"; \
	if [[ $$status == "false" || $$auto == "false" ]]; then \
		echo false; \
	else \
		echo true; \
	fi

# _package-disabled is an internal target called when an attempt is made to create
# a package but the package has been disabled.
_package-disabled:
	@echo Creating packages has been disabled for $(PACKAGE_NAME)
	@exit 0

# download.mk contains all the recipes for downloading and unpacking release bundles
include $(SELF_DIR)/download.mk
