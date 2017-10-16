TMP := ''
IMAGE := heroku/heroku:16-build
BASH_COMMAND := /bin/bash
GO_BUCKET_URL := file:///buildpack/test/assets

.PHONY: test shell quick publish docker test-assets
.DEFAULT: test
.NOTPARALLEL: docker test-assets

test: BASH_COMMAND := test/run
test: docker

shell: docker

quick: BASH_COMMAND := test/quick; bash
quick: docker

publish:
	bin/publish heroku/go

docker: test-assets
	$(eval TMP := $(shell bin/copy true))
	@echo "Running docker ($(IMAGE)) with /buildpack=$(TMP) ..."
	@docker run -v $(TMP):/buildpack:ro --rm -it -e "GITHUB_TOKEN=$(GITHUB_TOKEN)" -e "GO_BUCKET_URL=$(GO_BUCKET_URL)" $(IMAGE) bash -c "cd /buildpack; $(BASH_COMMAND)"
	@rm -rf $(TMP)

test-assets:
	@echo "Setting up test assets"
	@bin/fetch-test-assets