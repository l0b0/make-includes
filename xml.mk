# Use METHOD=git to sort only files in the Git index or working tree
# Use XML_FILES_COMMAND to provide your own command to get NUL-separated paths
FIND = /usr/bin/find
GIT = /usr/bin/git
PRINTF = /usr/bin/printf
XARGS = /usr/bin/xargs
XSLTPROC = /usr/bin/xsltproc
XML_EXTENSIONS ?= xml

sort_file := $(dir $(lastword $(MAKEFILE_LIST)))sort.xslt

xml_glob_list = $(addprefix *., $(XML_EXTENSIONS))
empty :=
space := $(empty) $(empty)

METHOD = find
ifeq ($(METHOD),git)
	XML_FILES_COMMAND ?= $(GIT) ls-files -z $(xml_glob_list)
else ifeq ($(METHOD),find)
	xml_names_list = $(subst $(space), -o -name ,$(xml_glob_list))
	XML_FILES_COMMAND ?= $(FIND) . -type f \( -name $(xml_names_list) \) -exec $(PRINTF) '%s\0' {} +
endif

.PHONY: sort-xml-files
sort-xml-files:
	$(XML_FILES_COMMAND) | $(XARGS) --null -I '{}' $(XSLTPROC) --output '{}' $(sort_file) '{}'
