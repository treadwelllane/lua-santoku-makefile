export VPFX = <% return variable_prefix %>

DEPS_DIRS = $(shell find deps/* -maxdepth 0 -type d 2>/dev/null)
DEPS_RESULTS = $(addsuffix /results.mk, $(DEPS_DIRS))

include $(DEPS_RESULTS)

all: $(DEPS_RESULTS) $(TEST_RUN_SH)
	@if [ -d lib ]; then $(MAKE) -C lib PARENT_DEPS_RESULTS="$(DEPS_RESULTS)"; fi
	@if [ -d bin ]; then $(MAKE) -C bin PARENT_DEPS_RESULTS="$(DEPS_RESULTS)"; fi

install: all
	@if [ -d lib ]; then $(MAKE) -C lib install; fi
	@if [ -d bin ]; then $(MAKE) -C bin install; fi

<% template:push(os.getenv("TEST") == "1") %>

TEST_RUN_SH = run.sh

test: $(TEST_RUN_SH)
	sh $(TEST_RUN_SH)

$(TEST_RUN_SH): $(PREAMBLE)
	@echo "Generating '$@'"
	@sh -c 'echo $(TEST_RUN_SH_DATA) | base64 -d | $(TOKU_TEMPLATE_TEST) -f - -o "$@"'

.PHONY: test

<% template:pop() %>

deps/%/results.mk: deps/%/Makefile
	@$(MAKE) -C "$(dir $@)"

.PHONY: all install
