export VPFX = <% return variable_prefix %>

DEPS_DIRS = $(shell find deps/* -maxdepth 1 -type d 2>/dev/null)
DEPS_RESULTS = $(addsuffix /results.mk, $(DEPS_DIRS))

include $(DEPS_RESULTS)

all: $(DEPS_RESULTS) lua.env
	@$(MAKE) -E "include $(addprefix ../, $(DEPS_RESULTS))" -C src
	@$(MAKE) -E "include $(addprefix ../, $(DEPS_RESULTS))" -C bin

test:
	@rm -f luacov.stats.out || true
	@. ./lua.env && $($(VPFX)_TEST_PREFIX) \
		toku test -i "$(LUA) -l luacov" --match "^.*%.lua$$" test/spec
	@luacov -c test/luacov.lua || true
	@cat luacov.report.out | awk '/^Summary/ { P = NR } P && NR > P + 1'
	@echo
	@luacheck --config test/luacheck.lua src bin test/spec || true
	@echo

install: all
	@$(MAKE) -C src install
	@$(MAKE) -C bin install

lua.env:
	@echo export LUA="$(LUA)" > lua.env

deps/%/results.mk: deps/%/Makefile
	@$(MAKE) -C "$(dir $@)"

.PHONY: all test install
