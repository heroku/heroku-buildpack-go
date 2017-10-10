IMAGE := "heroku/heroku:16-build"

.PHONY: test
test:
	@echo "Setting up test assets"
	@bin/fetch-test-assets
	@mkdir -p test/assets
	$(MAKE) IMAGE=$(IMAGE) BASH_COMMAND='cd /buildpack; test/run' docker
	@echo ""

shell:
	$(MAKE) IMAGE=$(IMAGE) BASH_COMMAND='mkdir -p /buildpack_test; tar --exclude=file-cache --exclude=.git -cf - -C /buildpack . | tar -x -C /buildpack_test; cd /buildpack_test/; bash' docker
	@echo ""

quick:
	$(MAKE) IMAGE=$(IMAGE) BASH_COMMAND='cd /buildpack; test/quick; bash' docker
	@echo ""

publish:
	bin/publish heroku/go

docker: GO_BUCKET_URL=file:///buildpack/test/assets
docker:
	@echo "Running docker ($(IMAGE))..."
	@docker run -v $(shell pwd):/buildpack:ro --rm -it -e "GITHUB_TOKEN=$(GITHUB_TOKEN)" -e "GO_BUCKET_URL=$(GO_BUCKET_URL)" $(IMAGE) bash -c '$(BASH_COMMAND)'