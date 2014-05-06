# Use METHOD=git to check only files in the Git index or working tree
METHOD = find
ifeq ($(METHOD),git)
	python_files_run = git ls-files -z '*.py' | xargs -0
else ifeq ($(METHOD),find)
	python_files_run = /usr/bin/find . -type f -name '*.py' -exec printf '%s\0' {} + | xargs -0
endif

PEP8_OPTIONS = --max-line-length 120

# Check Python code for all sorts of lint
.PHONY: python-lint
python-lint: python-pep8 python-pychecker python-pylint python-pyflakes

.PHONY: python-pep8
python-pep8:
	$(python_files_run) pep8 $(PEP8_OPTIONS)

.PHONY: python-pychecker
python-pychecker:
	$(python_files_run) pychecker

.PHONY: python-pylint
python-pylint:
	$(python_files_run) pylint

.PHONY: python-pyflakes
python-pyflakes:
	$(python_files_run) pyflakes

virtualenv-$(PYTHON_VERSION):
	virtualenv --python=$(shell which python$(PYTHON_VERSION)) virtualenv-$(PYTHON_VERSION)
