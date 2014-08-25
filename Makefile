TEMPORARY_DIRECTORY := $(shell mktemp -d)

.PHONY: test
test: test-posix-shell test-python test-variables

.PHONY: test-posix-shell
test-posix-shell:
	make posix-shell-test-syntax

.PHONY: test-python
test-python: test-python-pep8 test-python-virtualenv

.PHONY: test-python-pep8
test-python-pep8:
	make PYTHON_BUILD_DIRECTORY=$(TEMPORARY_DIRECTORY) virtualenv
	. virtualenv/bin/activate && \
		pip install --requirement=test/python-requirements.txt
	. virtualenv/bin/activate && \
		make python-pep8
	. virtualenv/bin/activate && \
		make METHOD=find python-pep8
	. virtualenv/bin/activate && \
		make METHOD=git python-pep8

.PHONY: test-python-virtualenv
test-python-virtualenv:
	for version in 2.6.9 3.4.1; do \
		make PYTHON_VERSION=$$version PYTHON_BUILD_DIRECTORY=$(TEMPORARY_DIRECTORY) virtualenv && \
			. virtualenv/bin/activate && \
			python --version 2>&1 | grep --fixed-strings --regexp=$$version || \
			exit $$?; \
	done

.PHONY: test-variables
test-variables:
	make variables | grep -q CURDIR
	make FOO=bar variables | grep --fixed-strings --quiet 'FOO = bar'
	make FOO=bar variable-FOO | grep --fixed-strings --quiet 'FOO = bar'

.PHONY: clean
clean:
	-$(RM) test/*.pyc
	-$(RM) virtualenv

include *.mk
