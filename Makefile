.PHONY: test
test: test-cedar-14

test-cedar-14:
	@echo "Running tests in docker (cedar-14)..."
	@docker run -v $(shell pwd):/buildpack:ro --rm -it -e "STACK=cedar-14" heroku/cedar:14 bash -c 'mkdir -p /buildpack_test; tar --exclude=file-cache --exclude=.git -cf - -C /buildpack . | tar -x -C /buildpack_test; cd /buildpack_test/; test/run;'
	@echo ""

shell:
	@echo "Opening cedar-14 shell..."
	@docker run -v $(shell pwd):/buildpack:ro --rm -it heroku/cedar:14 bash -c 'mkdir -p /buildpack_test; tar --exclude=file-cache --exclude=.git -cf - -C /buildpack . | tar -x -C /buildpack_test; cd /buildpack_test/; bash'
	@echo ""

quick:
	@echo "Opening cedar-14 shell..."
	@docker run -v $(shell pwd):/buildpack:ro --rm -it heroku/cedar:14 bash -c 'mkdir -p /buildpack_test; tar --exclude=file-cache --exclude=.git -cf - -C /buildpack . | tar -x -C /buildpack_test; cd /buildpack_test/; test/quick; bash'
	@echo ""

publish:
	bin/publish heroku/go