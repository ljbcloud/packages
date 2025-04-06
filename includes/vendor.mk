# this makefile is the one that should be included in every vendor/*/Makefile

# this gets the directory of the last Makefile opened, which here is the current one
SELF_DIR := $(dir $(lastword $(MAKEFILE_LIST)))

include $(SELF_DIR)/package.mk
