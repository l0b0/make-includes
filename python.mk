FIND := /usr/bin/find

# Check Python code for all sorts of lint
.PHONY: python-lint
python-lint: python-pep8 python-pychecker python-pylint python-pyflakes

.PHONY: python-pep8
python-pep8:
	$(FIND) . -type f -name '*.py' -exec pep8 {} +

.PHONY: python-pychecker
python-pychecker:
	$(FIND) . -type f -name '*.py' -exec pychecker {} +

.PHONY: python-pylint
python-pylint:
	$(FIND) . -type f -name '*.py' -exec pylint {} +

.PHONY: python-pyflakes
python-pyflakes:
	$(FIND) . -type f -name '*.py' -exec pyflakes {} +
