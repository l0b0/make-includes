# Use METHOD=git to check only files in the Git index or working tree
METHOD = find
ifeq ($(METHOD),git)
	python_files_run = git ls-files -z '*.py' | xargs -0
else ifeq ($(METHOD),find)
	python_files_run = /usr/bin/find . -type f -name '*.py' -exec printf '%s\0' {} + | xargs -0
endif

PYTHON_VERSION ?= $(shell python --version | cut -d ' ' -f 2 | cut -d '.' -f 1-3)
PYTHON_NAME ?= Python-$(PYTHON_VERSION)
PYTHON_SOURCE_DIRECTORY ?= $(python_build_directory)/$(PYTHON_NAME)
PYTHON_PREFIX ?= $(CURDIR)/build/$(PYTHON_NAME)-install
PYTHON_TARBALL ?= $(PYTHON_NAME).tgz
PYTHON_TARBALL_PATH ?= $(python_build_directory)/$(PYTHON_TARBALL)
PYTHON_DOWNLOAD_URL ?= https://www.python.org/ftp/python/$(PYTHON_VERSION)/$(PYTHON_TARBALL)
PYTHON_MAKEFILE ?= $(PYTHON_SOURCE_DIRECTORY)/Makefile
PYTHON_SOURCE_EXECUTABLE ?= $(PYTHON_SOURCE_DIRECTORY)/python
PYTHON_EXECUTABLE ?= $(PYTHON_PREFIX)/bin/python$(python_short_version)

VIRTUALENV_VERSION ?= $(shell virtualenv --version)
VIRTUALENV_NAME ?= virtualenv-$(VIRTUALENV_VERSION)
VIRTUALENV_SOURCE_DIRECTORY ?= $(virtualenv_build_directory)/$(VIRTUALENV_NAME)
VIRTUALENV_TARBALL ?= $(VIRTUALENV_NAME).tar.gz
VIRTUALENV_TARBALL_PATH ?= $(virtualenv_build_directory)/$(VIRTUALENV_TARBALL)
VIRTUALENV_DOWNLOAD_URL ?= https://pypi.python.org/packages/source/v/virtualenv/$(VIRTUALENV_TARBALL)
VIRTUALENV_EXECUTABLE ?= $(VIRTUALENV_SOURCE_DIRECTORY)/virtualenv.py

VIRTUALENV_DIRECTORY ?= virtualenv-$(PYTHON_VERSION)

python_build_directory ?= build/python
python_version_numbers = $(wordlist 1,3,$(subst ., ,$(PYTHON_VERSION)))
python_version_major = $(word 1,$(python_version_numbers))
python_version_minor = $(word 2,$(python_version_numbers))
python_version_patch = $(word 3,$(python_version_numbers))
python_short_version = $(python_version_major).$(python_version_minor)

virtualenv_build_directory ?= build/virtualenv
virtualenv_activate = $(VIRTUALENV_DIRECTORY)/bin/activate

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

$(PYTHON_TARBALL_PATH): $(python_build_directory)
	wget --timestamp --directory-prefix $(python_build_directory) $(PYTHON_DOWNLOAD_URL)

# Two targets in one to work around 1-second resolution on Make timestamps
$(PYTHON_MAKEFILE): $(PYTHON_TARBALL_PATH)
	tar --extract --gzip --directory $(dir $(PYTHON_TARBALL_PATH)) --file $(PYTHON_TARBALL_PATH)
	cd $(PYTHON_SOURCE_DIRECTORY) && ./configure --prefix $(PYTHON_PREFIX)

$(PYTHON_SOURCE_EXECUTABLE): $(PYTHON_MAKEFILE)
	make -C $(PYTHON_SOURCE_DIRECTORY)

$(PYTHON_EXECUTABLE): $(PYTHON_SOURCE_EXECUTABLE)
	make -C $(PYTHON_SOURCE_DIRECTORY) install

$(VIRTUALENV_TARBALL_PATH): $(virtualenv_build_directory)
	wget --timestamp --directory-prefix $(virtualenv_build_directory) $(VIRTUALENV_DOWNLOAD_URL)

$(VIRTUALENV_SOURCE_DIRECTORY): $(VIRTUALENV_TARBALL_PATH)
	tar --extract --gzip --directory $(dir $(VIRTUALENV_TARBALL_PATH)) --file $(VIRTUALENV_TARBALL_PATH)

$(VIRTUALENV_EXECUTABLE): $(VIRTUALENV_SOURCE_DIRECTORY)

$(VIRTUALENV_DIRECTORY): $(PYTHON_EXECUTABLE) $(VIRTUALENV_EXECUTABLE)
	$(VIRTUALENV_EXECUTABLE) --python=$(PYTHON_EXECUTABLE) $(VIRTUALENV_DIRECTORY)

.PHONY: virtualenv
virtualenv: $(VIRTUALENV_DIRECTORY)

.PHONY: clean-python
clean-python:
	rm --recursive --force $(python_build_directory) $(VIRTUALENV_DIRECTORY)

$(python_build_directory) $(virtualenv_build_directory):
	mkdir --parent $@
