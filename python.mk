# Use METHOD=git to check only files in the Git index or working tree

METHOD = find

method_find := /usr/bin/find . -type f -name '*.py' -exec printf '%s\0' {} +
method_git := git ls-files -z '*.py'

python_files_run = $(method_$(METHOD)) | xargs -0

# Check Python code for all sorts of lint
.PHONY: python-lint
python-lint: python-pep8 python-pychecker python-pylint python-pyflakes

.PHONY: python-pep8
python-pep8:
	$(python_files_run) pep8 --max-line-length 120

.PHONY: python-pychecker
python-pychecker:
	$(python_files_run) pychecker

.PHONY: python-pylint
python-pylint:
	$(python_files_run) pylint

.PHONY: python-pyflakes
python-pyflakes:
	$(python_files_run) pyflakes
