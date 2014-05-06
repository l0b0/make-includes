# Use METHOD=git to check only files in the Git index or working tree
METHOD = find
ifeq ($(METHOD),git)
	posix_files_run = git ls-files -z '*.sh' | xargs -0
else ifeq ($(METHOD),find)
	posix_files_run = /usr/bin/find . -type f -name '*.sh' -exec printf '%s\0' {} + | xargs -0
endif

# Check Python code for all sorts of lint
.PHONY: posix-shell-test-syntax
posix-shell-test-syntax:
	$(posix_files_run) sh -o noexec
