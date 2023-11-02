export VPFX = <% return variable_prefix %>

DEPS_DIRS = $(shell find deps/* -maxdepth 1 -type d 2>/dev/null)
DEPS_RESULTS = $(addsuffix /results.mk, $(DEPS_DIRS))

include $(DEPS_RESULTS)

all: $(DEPS_RESULTS) lua.env
	@if [ -d src ]; then $(MAKE) -E "include $(addprefix ../, $(DEPS_RESULTS))" -C src; fi
	@if [ -d bin ]; then $(MAKE) -E "include $(addprefix ../, $(DEPS_RESULTS))" -C bin; fi

install: all
	@if [ -d src ]; then $(MAKE) -C src install; fi
	@if [ -d bin ]; then $(MAKE) -C bin install; fi

ifeq ($(shell test -d test && echo 1),1)

test:
	@rm -f luacov.stats.out luacov.report.out || true
	@. ./lua.env && $($(VPFX)_TEST_PREFIX) \
		toku test -i "$(LUA) -l luacov" --match "^.*%.lua$$" test/spec
	@luacov -c test/luacov.lua || true
	@cat luacov.report.out | awk '/^Summary/ { P = NR } P && NR > P + 1'
	@echo
	@luacheck --config test/luacheck.lua src bin test/spec || true
	@echo

else

test:

endif

lua.env:
	@echo export LUA="$(LUA)" > lua.env

deps/%/results.mk: deps/%/Makefile
	@$(MAKE) -C "$(dir $@)"

.PHONY: all test install
