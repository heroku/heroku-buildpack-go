STACK ?= heroku-24
STACK_IMAGE_TAG := heroku/$(subst -,:,$(STACK))-build

.PHONY: test shell quick publish docker test-assets run run-ci
.DEFAULT: test
.NOTPARALLEL: docker test-assets

sync:
	./sbin/sync-files.sh

publish:
	@bash sbin/publish.sh

test-assets:
	@echo "Setting up test assets"
	@sbin/fetch-test-assets

test: BASH_COMMAND := test/run.sh
shell: BASH_COMMAND := /bin/bash

test shell: docker

quick: FIXTURE ?= govendor-basic
quick: run

# TODO: Add buildpack support for arm64 and use the native architecture for improved test performance locally.
docker: test-assets
	@echo "Running tests in docker using $(STACK_IMAGE_TAG)"
	@docker pull $(STACK_IMAGE_TAG)
	@docker run -v $(PWD):/buildpack:ro --rm -it -e "GITLAB_TOKEN=$(GITLAB_TOKEN)" -e "GITHUB_TOKEN=$(GITHUB_TOKEN)" -e "IMAGE=$(STACK_IMAGE_TAG)" --user root --platform linux/amd64 $(STACK_IMAGE_TAG) bash -c "cd /buildpack; $(BASH_COMMAND)"

define SETUP_BUILDPACK_ENV
	mkdir -p /tmp/buildpack /tmp/cache /tmp/env; \
	cp -r /src/{bin,lib,vendor,files.json,data.json} /tmp/buildpack; \
	cp -r /src/test/fixtures/$(FIXTURE) /tmp/build_1; \
	cd /tmp/buildpack; \
	unset $$(printenv | cut -d '=' -f 1 | grep -vE "^(HOME|LANG|PATH|STACK)$$");
endef

run:
	@echo "Running buildpack using: STACK=$(STACK) FIXTURE=$(FIXTURE)"
	@docker run --rm -v $(PWD):/src:ro --tmpfs /app:mode=1777 -e "HOME=/app" -e "STACK=$(STACK)" "$(STACK_IMAGE_TAG)" \
		bash -euo pipefail -O dotglob -c '\
			$(SETUP_BUILDPACK_ENV) \
			echo -en "\n~ Detect: " && ./bin/detect /tmp/build_1; \
			echo -e "\n~ Compile:" && ./bin/compile /tmp/build_1 /tmp/cache /tmp/env; \
			echo -e "\n~ Release:" && ./bin/release /tmp/build_1; \
			rm -rf /app/* /tmp/build_1; \
			cp -r /src/test/fixtures/$(FIXTURE) /tmp/build_2; \
			echo -e "\n~ Recompile:" && ./bin/compile /tmp/build_2 /tmp/cache /tmp/env; \
			echo -e "\nBuild successful!"; \
		'
	@echo

run-ci:
	@echo "Running buildpack CI scripts using: STACK=$(STACK) FIXTURE=$(FIXTURE)"
	@docker run --rm -v $(PWD):/src:ro --tmpfs /app:mode=1777 -e "HOME=/app" -e "STACK=$(STACK)" "$(STACK_IMAGE_TAG)" \
		bash -euo pipefail -O dotglob -c '\
			$(SETUP_BUILDPACK_ENV) \
			echo -e "\n~ Detect: " && ./bin/detect /tmp/build_1; \
			echo -e "\n~ Test Compile:" && ./bin/test-compile /tmp/build_1 /tmp/cache /tmp/env; \
			echo -e "\n~ Test:" && ./bin/test /tmp/build_1 /tmp/cache /tmp/env; \
			echo -e "\nTest compilation and execution successful!"; \
		'
	@echo
