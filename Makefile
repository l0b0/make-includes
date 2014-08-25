.PHONY: test
test: test-posix-shell test-python test-variables

.PHONY: test-posix-shell
test-posix-shell:
	make posix-shell-test-syntax

.PHONY: test-python
test-python: test-python-lint test-python-virtualenv

.PHONY: test-python-lint
test-python-lint: clean-python
	make python-lint
	make METHOD=find python-lint
	make METHOD=git python-lint

.PHONY: test-python-virtualenv
test-python-virtualenv: clean
	for version in 2.6.9 3.4.1; do \
		make PYTHON_VERSION=$$version virtualenv && \
		. virtualenv-$$version/bin/activate && python --version 2>&1 | grep --fixed-strings --regexp=$$version || exit $?; \
	done
	if which python; then \
		version=$(shell python --version | cut -d ' ' -f 2 | cut -d '.' -f 1-3) && \
		make PYTHON_VERSION=$$version virtualenv && \
		. virtualenv-$$version/bin/activate && python --version 2>&1 | grep --fixed-strings --regexp=$$version || exit $?; \
	fi

.PHONY: test-variables
test-variables:
	make variables | grep -q CURDIR
	make FOO=bar variables | grep --fixed-strings --quiet 'FOO = bar'
	make FOO=bar variable-FOO | grep --fixed-strings --quiet 'FOO = bar'

.PHONY: clean
clean:
	-$(RM) -r build/
	-$(RM) test/*.pyc
	-$(RM) -r virtualenv-*/

include *.mk
