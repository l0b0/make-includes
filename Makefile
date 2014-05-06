PYTHON_VERSION=$(shell python --version | cut -d ' ' -f 2 | cut -d '.' -f 1-2)

.PHONY: test
test: test-python test-variables

.PHONY: test-python
test-python: test-python-lint test-python-virtualenv

.PHONY: test-python-lint
test-python-lint: clean
	make python-lint
	make METHOD=find python-lint
	make METHOD=git python-lint

.PHONY: test-python-virtualenv
test-python-virtualenv:
	make virtualenv-$(PYTHON_VERSION) || exit 1
	. virtualenv-$(PYTHON_VERSION)/bin/activate && python --version 2>&1 | grep -Fe "$(PYTHON_VERSION)"

.PHONY: test-variables
test-variables:
	make variables | grep -q CURDIR
	make FOO=bar variables | grep -Fq 'FOO = bar'
	make FOO=bar variable-FOO | grep -Fq 'FOO = bar'

.PHONY: clean
clean:
	-rm test/*.pyc
	-rm -r virtualenv-*/

include *.mk
