GREP = /usr/bin/grep
MAKE = /usr/bin/make

TEMPORARY_DIRECTORY := $(shell mktemp -d)

VENV_VERSION = 13.1.2

.PHONY: test
test: test-posix-shell test-python test-variables

.PHONY: test-posix-shell
test-posix-shell:
	$(MAKE) posix-shell-test-syntax

.PHONY: test-python
test-python: test-python-pep8 test-python-virtualenv

.PHONY: test-python-pep8
test-python-pep8:
	$(MAKE) PYTHON_BUILD_DIRECTORY=$(TEMPORARY_DIRECTORY) virtualenv
	. virtualenv/bin/activate && \
		pip install --requirement=test/python-requirements.txt
	. virtualenv/bin/activate && \
		$(MAKE) python-pep8
	. virtualenv/bin/activate && \
		$(MAKE) METHOD=find python-pep8
	. virtualenv/bin/activate && \
		$(MAKE) METHOD=git python-pep8

.PHONY: test-python-virtualenv
test-python-virtualenv:
	for python_version in 2.7.10 3.5.0; do \
		for virtualenv_version in 12.1.1 13.1.2; do \
			$(MAKE) PYTHON_VERSION=$$python_version PYTHON_BUILD_DIRECTORY=$(TEMPORARY_DIRECTORY) VENV_VERSION=$$virtualenv_version virtualenv && \
				. virtualenv/bin/activate && \
				python --version 2>&1 | $(GREP) --fixed-strings --regexp=$$version || \
				exit $$?; \
		done \
	done
	$(RM) -r $(TEMPORARY_DIRECTORY)/virtualenv-3.4.1
	$(MAKE) ONLINE=false PYTHON_VERSION=3.4.1 PYTHON_BUILD_DIRECTORY=$(TEMPORARY_DIRECTORY) virtualenv && \
		. virtualenv/bin/activate && \
		python --version 2>&1 | $(GREP) --fixed-strings --regexp=$$version || \
		exit $$?;


.PHONY: test-variables
test-variables:
	$(MAKE) variables | $(GREP) -q CURDIR
	$(MAKE) FOO=bar variables | $(GREP) --fixed-strings --quiet 'FOO = bar'
	$(MAKE) FOO=bar variable-FOO | $(GREP) --fixed-strings --quiet 'FOO = bar'

.PHONY: clean
clean:
	-$(RM) build
	-$(RM) virtualenv

include *.mk
