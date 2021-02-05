TMP := ''
IMAGE := heroku/heroku:20-build
BASH_COMMAND := /bin/bash
GO_BUCKET_URL := file:///buildpack/test/assets

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
	$(eval TMP := $(shell sbin/copy true))
	@echo "Running docker ($(IMAGE)) with /buildpack=$(TMP) ..."
	@docker pull $(IMAGE)
	@docker run -v $(TMP):/buildpack:ro --rm -it -e "GITLAB_TOKEN=$(GITLAB_TOKEN)" -e "GITHUB_TOKEN=$(GITHUB_TOKEN)" -e "GO_BUCKET_URL=$(GO_BUCKET_URL)" -e "IMAGE=$(IMAGE)" $(IMAGE) bash -c "cd /buildpack; $(BASH_COMMAND)"
	@rm -rf $(TMP)

test-assets:
	@echo "Setting up test assets"
	@sbin/fetch-test-assets
