.PHONY: test
test: test-python test-variables

.PHONY: test-python
test-python: test-python-lint

.PHONY: test-python-lint
test-python-lint:
	make python-lint
	METHOD=find make python-lint
	METHOD=git make python-lint

.PHONY: test-variables
test-variables:
	make variables | grep -q CURDIR
	make FOO=bar variables | grep -Fq 'FOO = bar'
	make FOO=bar variable-FOO | grep -Fq 'FOO = bar'

.PHONY: clean
clean:
	-rm test/*.pyc

include *.mk
