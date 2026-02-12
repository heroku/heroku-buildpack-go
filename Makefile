STACK ?= heroku-24
STACK_IMAGE_TAG := heroku/$(subst -,:,$(STACK))-build
FIXTURE ?= test/fixtures/mod-basic-go126
# TODO: Add buildpack support for arm64 and use the native architecture for improved test performance locally.
DOCKER_FLAGS := --rm --platform linux/amd64 -v $(PWD):/src:ro

.PHONY: test publish test-assets run run-ci
.DEFAULT: test
.NOTPARALLEL: test-assets

sync:
	./sbin/sync-files.sh

publish:
	@bash sbin/publish.sh

test-assets:
	@echo "Setting up test assets"
	@sbin/fetch-test-assets

test: test-assets
	@echo "Running tests using: STACK=$(STACK) TEST=$(TEST)"
	@docker run $(DOCKER_FLAGS) "$(STACK_IMAGE_TAG)" \
		bash -euo pipefail -O dotglob -c '\
			cd /src; \
			test/run.sh $(if "$(TEST)",-- "$(TEST)"); \
			echo -e "\nTest run was successful!"; \
		'
	@echo

define SETUP_BUILDPACK_ENV
	mkdir -p /tmp/buildpack /tmp/cache /tmp/env; \
	cp -r /src/{bin,lib,vendor,files.json,data.json} /tmp/buildpack; \
	cp -r /src/$(FIXTURE) /tmp/build_1; \
	cd /tmp/buildpack; \
	unset $$(printenv | cut -d '=' -f 1 | grep -vE "^(HOME|LANG|PATH|STACK)$$");
endef

run:
	@echo "Running buildpack using: STACK=$(STACK) FIXTURE=$(FIXTURE)"
	@docker run $(DOCKER_FLAGS) --tmpfs /app:mode=1777 -e "HOME=/app" "$(STACK_IMAGE_TAG)" \
		bash -euo pipefail -O dotglob -c '\
			$(SETUP_BUILDPACK_ENV) \
			echo -en "\n~ Detect: " && ./bin/detect /tmp/build_1; \
			echo -e "\n~ Compile:" && ./bin/compile /tmp/build_1 /tmp/cache /tmp/env; \
			echo -e "\n~ Release:" && ./bin/release /tmp/build_1; \
			rm -rf /app/* /tmp/build_1; \
			cp -r /src/$(FIXTURE) /tmp/build_2; \
			echo -e "\n~ Recompile:" && ./bin/compile /tmp/build_2 /tmp/cache /tmp/env; \
			echo -e "\nBuild successful!"; \
		'
	@echo

run-ci:
	@echo "Running buildpack CI scripts using: STACK=$(STACK) FIXTURE=$(FIXTURE)"
	@docker run $(DOCKER_FLAGS) --tmpfs /app:mode=1777 -e "HOME=/app" "$(STACK_IMAGE_TAG)" \
		bash -euo pipefail -O dotglob -c '\
			$(SETUP_BUILDPACK_ENV) \
			echo -e "\n~ Detect: " && ./bin/detect /tmp/build_1; \
			echo -e "\n~ Test Compile:" && ./bin/test-compile /tmp/build_1 /tmp/cache /tmp/env; \
			echo -e "\n~ Test:" && ./bin/test /tmp/build_1 /tmp/cache /tmp/env; \
			echo -e "\nTest compilation and execution successful!"; \
		'
	@echo
