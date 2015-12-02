GIT = /usr/bin/git
MAKE = /usr/bin/make

.PHONY: test-clean
test-clean:
	$(MAKE) clean
	! $(GIT) clean --dry-run -dx | grep .
