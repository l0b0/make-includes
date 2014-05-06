make-includes
=============

Files used by Makefiles in several other projects.

Test
----

    make test

Overrides
---------

- `python` version:

        make PYTHON_VERSION='2.7' test
        make PYTHON_VERSION='2.7' virtualenv
- `pep8` options:

        make PEP8_OPTIONS='--max-line-length=120' python-pep8
