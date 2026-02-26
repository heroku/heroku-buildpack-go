.PHONY: test test-assets run run-ci sync publish

STACK ?= heroku-24
FIXTURE ?= test/fixtures/mod-basic-go126
# Allow overriding the exit code in CI, so we can test bin/report works for failing builds.
COMPILE_FAILURE_EXIT_CODE ?= 1

# Converts a stack name of `heroku-NN` to its build Docker image tag of `heroku/heroku:NN-build`.
STACK_IMAGE_TAG := heroku/$(subst -,:,$(STACK))-build
# TODO: Add buildpack support for arm64 and use the native architecture for improved test performance locally.
DOCKER_FLAGS := --rm --platform linux/amd64 -v $(PWD):/src:ro

test: test-assets
	@echo "Running tests using: STACK=$(STACK) TEST=$(TEST)"
	@docker run $(DOCKER_FLAGS) "$(STACK_IMAGE_TAG)" \
		bash -euo pipefail -O dotglob -c '\
			cd /src; \
			test/run.sh $(if $(TEST),-- "$(TEST)"); \
			echo -e "\nTest run was successful!"; \
		'
	@echo

test-assets:
	@echo "Setting up test assets"
	@sbin/fetch-test-assets

# Files that still exist in S3 but have been removed from files.json.
# Passed as ignore arguments so sync-files.sh doesn't fail on the mismatch.
SYNC_IGNORE := \
	dep-linux-amd64 \
	dep-v0.3.1-linux-amd64 \
	dep-v0.4.0-linux-amd64 \
	dep-v0.4.1-linux-amd64 \
	dep-v0.5.0-linux-amd64 \
	dep-v0.5.1-linux-amd64 \
	dep-v0.5.2-linux-amd64 \
	errors-0.8.0.tar.gz \
	gb-0.4.3.tar.gz \
	gb-0.4.4-pre.tar.gz \
	gb-0.4.4.tar.gz \
	glide-v0.12.3-linux-amd64.tar.gz \
	glide-v0.13.3-linux-amd64.tar.gz \
	go.go1.linux-amd64.tar.gz \
	go1.0.1.linux-amd64.tar.gz \
	go1.0.2.linux-amd64.tar.gz \
	go1.0.3.linux-amd64.tar.gz \
	go1.1.1.linux-amd64.tar.gz \
	go1.1.2.linux-amd64.tar.gz \
	go1.1.linux-amd64.tar.gz \
	go1.10.1.linux-amd64.tar.gz \
	go1.10.2.linux-amd64.tar.gz \
	go1.10.3.linux-amd64.tar.gz \
	go1.10.4.linux-amd64.tar.gz \
	go1.10.5.linux-amd64.tar.gz \
	go1.10.6.linux-amd64.tar.gz \
	go1.10.7.linux-amd64.tar.gz \
	go1.10.8.linux-amd64.tar.gz \
	go1.10.linux-amd64.tar.gz \
	go1.10beta1.linux-amd64.tar.gz \
	go1.10beta2.linux-amd64.tar.gz \
	go1.10rc1.linux-amd64.tar.gz \
	go1.10rc2.linux-amd64.tar.gz \
	go1.2.1.linux-amd64.tar.gz \
	go1.2.2.linux-amd64.tar.gz \
	go1.2.linux-amd64.tar.gz \
	go1.3.1.linux-amd64.tar.gz \
	go1.3.2.linux-amd64.tar.gz \
	go1.3.3.linux-amd64.tar.gz \
	go1.3.linux-amd64.tar.gz \
	go1.4.1.linux-amd64.tar.gz \
	go1.4.2.linux-amd64.tar.gz \
	go1.4.3.linux-amd64.tar.gz \
	go1.4.linux-amd64.tar.gz \
	go1.5.1.linux-amd64.tar.gz \
	go1.5.2.linux-amd64.tar.gz \
	go1.5.3.linux-amd64.tar.gz \
	go1.5.4.linux-amd64.tar.gz \
	go1.5.linux-amd64.tar.gz \
	go1.6.1.linux-amd64.tar.gz \
	go1.6.2.linux-amd64.tar.gz \
	go1.6.3.linux-amd64.tar.gz \
	go1.6.4.linux-amd64.tar.gz \
	go1.6.linux-amd64.tar.gz \
	go1.7.1.linux-amd64.tar.gz \
	go1.7.3.linux-amd64.tar.gz \
	go1.7.4.linux-amd64.tar.gz \
	go1.7.5.linux-amd64.tar.gz \
	go1.7.6.linux-amd64.tar.gz \
	go1.7.linux-amd64.tar.gz \
	go1.8.1.linux-amd64.tar.gz \
	go1.8.2.linux-amd64.tar.gz \
	go1.8.3.linux-amd64.tar.gz \
	go1.8.4.linux-amd64.tar.gz \
	go1.8.5.linux-amd64.tar.gz \
	go1.8.7.linux-amd64.tar.gz \
	go1.8.linux-amd64.tar.gz \
	go1.8beta1.linux-amd64.tar.gz \
	go1.8beta2.linux-amd64.tar.gz \
	go1.8rc1.linux-amd64.tar.gz \
	go1.8rc2.linux-amd64.tar.gz \
	go1.8rc3.linux-amd64.tar.gz \
	go1.9.1.linux-amd64.tar.gz \
	go1.9.2.linux-amd64.tar.gz \
	go1.9.3.linux-amd64.tar.gz \
	go1.9.4.linux-amd64.tar.gz \
	go1.9.5.linux-amd64.tar.gz \
	go1.9.6.linux-amd64.tar.gz \
	go1.9.7.linux-amd64.tar.gz \
	go1.9.linux-amd64.tar.gz \
	go1.9beta1.linux-amd64.tar.gz \
	go1.9beta2.linux-amd64.tar.gz \
	go1.9rc1.linux-amd64.tar.gz \
	go1.9rc2.linux-amd64.tar.gz \
	godep_linux_amd64 \
	govendor_linux_amd64 \
	mercurial-3.9.tar.gz \
	migrate-v3.0.0-linux-amd64.tar.gz \
	migrate-v3.4.0-linux-amd64.tar.gz \
	tq-v0.4-linux-amd64 \
	tq-v0.5-linux-amd64

sync:
	@sbin/sync-files.sh $(SYNC_IGNORE)

publish:
	@bash sbin/publish.sh

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
			echo -e "\n~ Compile:" && { ./bin/compile /tmp/build_1 /tmp/cache /tmp/env || COMPILE_FAILED=1; }; \
			echo -e "\n~ Report:" && ./bin/report /tmp/build_1 /tmp/cache /tmp/env; \
			[[ "$${COMPILE_FAILED:-}" == "1" ]] && exit $(COMPILE_FAILURE_EXIT_CODE); \
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
