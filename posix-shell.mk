# Use METHOD=git to check only files in the Git index or working tree
FIND = /usr/bin/find
GIT = /usr/bin/git
SH = /usr/bin/sh
XARGS = /usr/bin/xargs

METHOD = find
ifeq ($(METHOD),git)
	posix_files_run = $(GIT) ls-files -z '*.sh' | $(XARGS) -0
else ifeq ($(METHOD),find)
	posix_files_run = $(FIND) . -type f -name '*.sh' -exec printf '%s\0' {} + | $(XARGS) -0
endif

# Check Python code for all sorts of lint
.PHONY: posix-shell-test-syntax
posix-shell-test-syntax:
	$(posix_files_run) $(SH) -o noexec
