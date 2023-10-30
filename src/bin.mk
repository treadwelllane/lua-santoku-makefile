BIN_LUA = $(shell find * -name '*.lua')

INST_LUA = $(addprefix $(INST_BINDIR)/, $(BIN_LUA))

all:
	@# Nothing to do here

install: $(INST_LUA)

$(INST_BINDIR)/%.lua: ./%.lua
	mkdir -p $(dir $@)
	cp $< $@

.PHONY: all install
