export VPFX = <% return variable_prefix %>

DEPS_DIRS = $(shell find deps/* -maxdepth 1 -type d)
DEPS_RESULTS = $(addsuffix /results.mk, $(DEPS_DIRS))

SRC_LUA = $(shell find * -name '*.lua')
SRC_C = $(shell find * -name '*.c')
SRC_O = $(SRC_C:.c=.o)
SRC_SO = $(SRC_O:.o=.$(LIB_EXTENSION))

INST_LUA = $(addprefix $(INST_LUADIR)/, $(SRC_LUA))
INST_SO = $(addprefix $(INST_LIBDIR)/, $(SRC_SO))

LIB_CFLAGS = -Wall $(PYTHON_CFLAGS) -I$(LUA_INCDIR)
LIB_LDFLAGS = -Wall $(PYTHON_LDFLAGS) -L$(LUA_LIBDIR)

ifeq ($($(VPFX)_SANITIZE),1)
LIB_CFLAGS += -fsanitize=address -fsanitize=leak
LIB_LDFLAGS += -fsanitize=address -fsanitize=leak
endif

include $(DEPS_RESULTS)

all: $(DEPS_RESULTS) lua.env
	@$(MAKE) -E "include $(addprefix ../, $(DEPS_RESULTS))" -C src

test:
	@rm -f luacov.stats.out || true
	@. ./lua.env && $($(VPFX)_TEST_PREFIX) toku test -i "$(LUA) -W -l luacov" --match "^.*%.lua$$" test/spec
	@echo
	@luacheck --config test/luacheck.lua src test/spec || true
	@luacov -c test/luacov.lua || true
	@cat luacov.report.out | awk '/^Summary/ { P = NR } P && NR > P + 1'
	@echo

install: all
	@$(MAKE) -C src install

lua.env:
	@echo export LUA="$(LUA)" > lua.env

deps/%/results.mk: deps/%/Makefile
	@$(MAKE) -C "$(dir $@)"

.PHONY: all test install
