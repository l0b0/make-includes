CP = /usr/bin/cp
DIFF = /usr/bin/diff
GREP = /usr/bin/grep
MAKE = /usr/bin/make
PRINTF = /usr/bin/printf

TEMPORARY_DIRECTORY := $(shell mktemp -d)

VENV_VERSION = 15.1.0

test_directory = test
xml_test_template = $(test_directory)/test.xml.orig
xml_test_file = $(test_directory)/test.xml
expected_xml_result_file = $(test_directory)/result.xml.test

.PHONY: test
test: test-posix-shell test-python test-variables
	$(MAKE) test-post-build

.PHONY: test-post-build
test-post-build: test-post-build-clean

.PHONY: test-post-build-clean
test-post-build-clean: test-clean

.PHONY: test-posix-shell
test-posix-shell: posix-shell-test-syntax

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
	for python_version in 2.7.13 3.6.0; do \
		for virtualenv_version in 12.1.1 13.1.2 14.0.6 15.1.0; do \
			$(MAKE) PYTHON_VERSION=$$python_version PYTHON_BUILD_DIRECTORY=$(TEMPORARY_DIRECTORY) VENV_VERSION=$$virtualenv_version virtualenv && \
				. virtualenv/bin/activate && \
				python --version 2>&1 | $(GREP) --fixed-strings --regexp=$$version && \
				deactivate || \
				exit $$?; \
		done \
	done
	$(RM) -r $(TEMPORARY_DIRECTORY)/virtualenv-3.4.1
	$(MAKE) ONLINE=false PYTHON_VERSION=3.6.0 PYTHON_BUILD_DIRECTORY=$(TEMPORARY_DIRECTORY) virtualenv && \
		. virtualenv/bin/activate && \
		python --version 2>&1 | $(GREP) --fixed-strings --regexp=$$version || \
		exit $$?;


.PHONY: test-variables
test-variables:
	$(MAKE) variables | $(GREP) -q CURDIR
	$(MAKE) FOO=bar variables | $(GREP) --fixed-strings --quiet 'FOO = bar'
	$(MAKE) FOO=bar variable-FOO | $(GREP) --fixed-strings --quiet 'FOO = bar'

.PHONY: test-xml
test-xml:
	$(CP) $(xml_test_template) $(xml_test_file)
	$(MAKE) METHOD=find sort-xml-files
	$(DIFF) $(xml_test_file) $(expected_xml_result_file)

.PHONY: clean
clean:
	-$(RM) build
	-$(RM) virtualenv
	-$(RM) $(xml_test_file)

include *.mk
