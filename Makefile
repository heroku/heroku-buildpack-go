TMP := ''
IMAGE := heroku/heroku:20-build
BASH_COMMAND := /bin/bash

.PHONY: test shell quick publish docker test-assets
.DEFAULT: test
.NOTPARALLEL: docker test-assets

sync:
	./sbin/sync-files.sh

test: BASH_COMMAND := test/run.sh
test: docker

shell: docker

quick: BASH_COMMAND := test/quick.sh; bash
quick: docker

# make FIXTURE=<fixture name> ENV=<FOO=BAR> compile
compile: BASH_COMMAND := test/quick.sh compile $(FIXTURE) $(ENV); bash
compile: docker

testpack: BASH_COMMAND := test/quick.sh dotest $(FIXTURE) $(ENV); bash
testpack: docker

publish:
	@bash sbin/publish.sh

docker: test-assets
	@echo "Running tests in docker using $(IMAGE)"
	@docker pull $(IMAGE)
	@docker run -v $(PWD):/buildpack:ro --rm -it -e "GITLAB_TOKEN=$(GITLAB_TOKEN)" -e "GITHUB_TOKEN=$(GITHUB_TOKEN)" -e "IMAGE=$(IMAGE)" $(IMAGE) bash -c "cd /buildpack; $(BASH_COMMAND)"

test-assets:
	@echo "Setting up test assets"
	@sbin/fetch-test-assets
