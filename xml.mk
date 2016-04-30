# Use METHOD=git to sort only files in the Git index or working tree
# Use XML_FILES_COMMAND to provide your own command to get NUL-separated paths
FIND = /usr/bin/find
GIT = /usr/bin/git
PRINTF = /usr/bin/printf
XARGS = /usr/bin/xargs
XSLTPROC = /usr/bin/xsltproc

sort_file := $(dir $(lastword $(MAKEFILE_LIST)))sort.xslt

METHOD = find
ifeq ($(METHOD),git)
	XML_FILES_COMMAND ?= $(GIT) ls-files -z '*.xml'
else ifeq ($(METHOD),find)
	XML_FILES_COMMAND ?= $(FIND) . -type f -name '*.xml' -exec $(PRINTF) '%s\0' {} +
endif

.PHONY: sort-xml-files
sort-xml-files:
	$(XML_FILES_COMMAND) | $(XARGS) --null -I '{}' $(XSLTPROC) --output '{}' $(sort_file) '{}'
