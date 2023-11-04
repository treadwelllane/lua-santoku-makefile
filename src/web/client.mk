<% sys = require("santoku.system") %>

all:

DEPS_DIRS = $(shell find deps/* -maxdepth 0 -type d 2>/dev/null)
DEPS_RESULTS = $(addsuffix /results.mk, $(DEPS_DIRS))

include $(DEPS_RESULTS)

ROCKSPEC = $(BUILD_DIR)/client/$(NAME)-client-$(VERSION).rockspec

# TODO: Omit in dev
ERUDA_JS = $(DIST_DIR)/public/eruda.js

RES = $(patsubst res/%, $(DIST_DIR)/public/%, $(shell find res -type f 2>/dev/null))
STATIC = $(patsubst static/%, $(DIST_DIR)/public/%, $(shell find static -type f 2>/dev/null))

DEPS = $(ROCKSPEC) $(ERUDA_JS)
DEPS += $(RES) $(STATIC)

all: $(DEPS) luarocks

luarocks:
	$(CLIENT_LUAROCKS) make $(ROCKSPEC)

$(ROCKSPEC): $(MAIN_CONFIG)
	@echo "Generating '$@'"
	@sh -c 'echo $(ROCKSPEC_DATA) | base64 -d | $(TOKU_TEMPLATE_CLIENT) -f - -o "$@"'

$(ERUDA_JS):
	@mkdir -p "$(dir $@)"
	wget http://cdn.jsdelivr.net/npm/eruda -O "$@"

$(DIST_DIR)/%: %
	@echo "Copying '$<' -> '$@'"
	mkdir -p "$(dir $@)"
	cp "$<" "$@"

$(DIST_DIR)/public/%: res/%
	@echo "Copying '$<' -> '$@'"
	mkdir -p "$(dir $@)"
	cp "$<" "$@"

$(DIST_DIR)/public/%: static/%
	@echo "Copying '$<' -> '$@'"
	mkdir -p "$(dir $@)"
	cp "$<" "$@"

deps/%/results.mk: deps/%/Makefile
	@$(MAKE) -C "$(dir $@)"

.PHONY: all luarocks
