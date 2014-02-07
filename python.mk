# Use METHOD=git to check only files in the Git index or working tree

METHOD = find

method_find := /usr/bin/find . -type f -name '*.py' -exec printf '%s\0' {} +
method_git := git ls-files -z '*.py'

find = $(method_$(METHOD))

# Check Python code for all sorts of lint
.PHONY: python-lint
python-lint: python-pep8 python-pychecker python-pylint python-pyflakes

.PHONY: python-pep8
python-pep8:
	$(find) | xargs -0 pep8 --max-line-length 120

.PHONY: python-pychecker
python-pychecker:
	$(find) | xargs -0 pychecker

.PHONY: python-pylint
python-pylint:
	$(find) | xargs -0 pylint

.PHONY: python-pyflakes
python-pyflakes:
	$(find) | xargs -0 pyflakes
