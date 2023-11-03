export VPFX = <% return variable_prefix %>

DEPS_DIRS = $(shell find deps/* -maxdepth 0 -type d 2>/dev/null)
DEPS_RESULTS = $(addsuffix /results.mk, $(DEPS_DIRS))

include $(DEPS_RESULTS)

all: $(DEPS_RESULTS)
	@if [ -d src ]; then $(MAKE) -E "include $(addprefix ../, $(DEPS_RESULTS))" -C src; fi
	@if [ -d bin ]; then $(MAKE) -E "include $(addprefix ../, $(DEPS_RESULTS))" -C bin; fi

install: all
	@if [ -d src ]; then $(MAKE) -C src install; fi
	@if [ -d bin ]; then $(MAKE) -C bin install; fi

<% template:push(os.getenv("TEST") == "1") %>

test:
	@rm -f luacov.stats.out luacov.report.out || true
	@if [ -d spec ]; then . ./lua.env && $(TEST_PREFIX) \
		toku test -i "$$LUA -l luacov" --match "^.*%.lua$$" spec; fi
	@if [ -f luacov.lua ]; then luacov -c luacov.lua; fi
	@if [ -f luacov.report.out ]; then cat luacov.report.out | awk '/^Summary/ { P = NR } P && NR > P + 1'; fi
	@echo
	@if [ -f luacheck.lua ]; then luacheck --config luacheck.lua $$(find src bin spec -maxdepth 0 2>/dev/null); fi
	@echo

.PHONY: test

<% template:pop() %>

deps/%/results.mk: deps/%/Makefile
	@$(MAKE) -C "$(dir $@)"

.PHONY: all install
