.PHONY: all
all: install

.PHONY: run
run: install
	pipenv run python sandbox.py

# SYSTEM DEPENDENCIES ##########################################################

.PHONY: memcached-start
memcached-start:
	nohup memcached -m 1000 &> memcached.log & echo $$! > memcached.pid
	@ echo
	@ echo "Memcached started (pid: `cat memcached.pid`)"

.PHONY: memcached-stop
memcached-stop:
	- pkill -F memcached.pid
	 @ rm -f memcached.pid
	 @ echo
	 @ echo "Memcached stopped"

# PROJECT DEPENDENCIES #########################################################

export PIPENV_SHELL_COMPAT=true
export PIPENV_VENV_IN_PROJECT=true

ENV := .venv
DEPENDENCIES := $(ENV)/.installed
PIP := $(ENV)/bin/pip

.PHONY: install
install: $(DEPENDENCIES)

$(DEPENDENCIES): $(PIP) Pipfile*
	pipenv install --dev --ignore-hashes
	@ touch $@

$(PIP):
	pipenv --python=python3.6

# VALIDATION ###################################################################

.PHONY: test
test: install
	pipenv run py.test

# CLEANUP ######################################################################

.PHONY: clean
	rm -rf $(shell pipenv --venv)
