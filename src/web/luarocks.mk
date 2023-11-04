LIB_LUA = $(shell find lib -name '*.lua' 2>/dev/null)
INST_LUA = $(patsubst lib/%, $(INST_LUADIR)/%, $(LIB_LUA))

all:
	@# do nothing

install: $(INST_LUA)

$(INST_LUADIR)/%.lua: ./lib/%.lua
	mkdir -p "$(dir $@)"
	cp "$<" "$@"

deps/%/results.mk: deps/%/Makefile
	@$(MAKE) -C "$(dir $@)"

.PHONY: all install
