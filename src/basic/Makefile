<% sys = require("santoku.system") %>

all:

-include config.mk

export ROOT_DIR = $(PWD)
export BUILD_BASE_DIR = $(ROOT_DIR)/.build
export PREAMBLE = $(BUILD_BASE_DIR)/preamble.mk

include $(PREAMBLE)

ifndef $(VPFX)_ENV
export $(VPFX)_ENV = default
endif

# NOTE: This allows callers to override install location
LUAROCKS ?= luarocks

export BUILD_DIR = $(BUILD_BASE_DIR)/$($(VPFX)_ENV)

TOKU_TEMPLATE = BUILD_DIR="$(BUILD_DIR)" toku template -M -c $(ROOT_DIR)/config.lua
export TOKU_TEMPLATE_TEST = TEST=1 $(TOKU_TEMPLATE)
ROCKSPEC = $(BUILD_DIR)/$(NAME)-$(VERSION).rockspec

LIB = $(shell find lib -type f 2>/dev/null)
BIN = $(shell find bin -type f 2>/dev/null)
TEST = $(shell find test -type f 2>/dev/null)
RES = $(shell find res -type f 2>/dev/null)
DEPS = $(shell find deps -type f 2>/dev/null)

LUAROCKS_MK = $(BUILD_DIR)/Makefile

ifneq ($(LIB),)
LIB_MK = $(BUILD_DIR)/lib/Makefile
endif

ifneq ($(BIN),)
BIN_MK = $(BUILD_DIR)/bin/Makefile
endif

TEST_LIB_MK = $(BUILD_DIR)/test/lib/Makefile
TEST_BIN_MK = $(BUILD_DIR)/test/bin/Makefile
TEST_ROCKSPEC = $(BUILD_DIR)/test/$(NAME)-$(VERSION).rockspec
TEST_LUAROCKS = LUAROCKS_CONFIG=$(TEST_LUAROCKS_CFG) luarocks
TEST_LUAROCKS_CFG = $(BUILD_DIR)/test/luarocks.lua
TEST_LUAROCKS_MK = $(BUILD_DIR)/test/Makefile
TEST_ENV = $(BUILD_DIR)/test/lua.env
TEST_LUACOV_CFG = $(BUILD_DIR)/test/luacov.lua
TEST_LUACHECK_CFG = $(BUILD_DIR)/test/luacheck.lua

PREAMBLE_DATA = <% return check(sys.sh("base64 -w0 < src/basic/preamble.mk")):co():head() %>
ROCKSPEC_DATA = <% return check(sys.sh("base64 -w0 < src/basic/template.rockspec")):co():head() %>

LUAROCKS_MK_DATA = <% return check(sys.sh("base64 -w0 < src/basic/luarocks.mk")):co():head() %>

LIB_MK_DATA = <% return check(sys.sh("base64 -w0 < src/basic/lib.mk")):co():head() %>
BIN_MK_DATA = <% return check(sys.sh("base64 -w0 < src/basic/bin.mk")):co():head() %>

TEST_LUAROCKS_CFG_DATA = <% return check(sys.sh("base64 -w0 < src/basic/luarocks.lua")):co():head() %>
TEST_LUACOV_DATA = <% return check(sys.sh("base64 -w0 < src/basic/luacov.lua")):co():head() %>
TEST_LUACHECK_DATA = <% return check(sys.sh("base64 -w0 < src/basic/luacheck.lua")):co():head() %>

export TEST_RUN_SH_DATA = <% return check(sys.sh("base64 -w0 < src/basic/test-run.sh")):co():head() %>

CONFIG_DEPS = $(lastword $(MAKEFILE_LIST))
CONFIG_DEPS += $(ROCKSPEC) $(LUAROCKS_MK) $(LIB_MK) $(BIN_MK)
CONFIG_DEPS += $(TEST_ROCKSPEC) $(TEST_LUAROCKS_MK) $(TEST_LIB_MK) $(TEST_BIN_MK) $(TEST_LUAROCKS_CFG)
CONFIG_DEPS += $(TEST_ENV) $(TEST_LUACOV_CFG) $(TEST_LUACHECK_CFG)
CONFIG_DEPS += $(addprefix $(BUILD_DIR)/, $(LIB) $(BIN) $(TEST) $(RES) $(DEPS))
CONFIG_DEPS += $(addprefix $(BUILD_DIR)/test/, $(LIB) $(BIN) $(RES) $(DEPS))

TARBALL = $(TARBALL_DIR).tar.gz
TARBALL_DIR = $(NAME)-$(VERSION)
TARBALL_SRCS = Makefile lib/Makefile bin/Makefile $(shell find lib bin deps res -type f 2>/dev/null)

all: $(CONFIG_DEPS)
	@echo "Running all"

install: all
	@echo "Running install"
	cd $(BUILD_DIR) && $(LUAROCKS) make $(ROCKSPEC) $(LUAROCKS_VARS)

test: all
	@echo "Running test"
	cd $(BUILD_DIR)/test && $(TEST_LUAROCKS) make $(TEST_ROCKSPEC) $(LUAROCKS_VARS)
	cd $(BUILD_DIR)/test && $(TEST_LUAROCKS) test $(TEST_ROCKSPEC) $(LUAROCKS_VARS)

iterate: all
	@echo "Running iterate"
	@while true; do \
		$(MAKE) test; \
		inotifywait -qqr -e close_write -e create -e delete $(filter-out tmp, $(wildcard *)); \
	done

ifeq ($($(VPFX)_PUBLIC),1)

tarball:
	@rm -f $(BUILD_DIR)/$(TARBALL) || true
	cd $(BUILD_DIR) && \
		tar --dereference --transform 's#^#$(TARBALL_DIR)/#' -czvf $(TARBALL) \
			$$(ls $(TARBALL_SRCS) 2>/dev/null)

check-release-status:
	@if test -z "$(LUAROCKS_API_KEY)"; then echo "Missing LUAROCKS_API_KEY variable"; exit 1; fi
	@if ! git diff --quiet; then echo "Commit your changes first"; exit 1; fi

github-release: check-release-status tarball
	gh release create --generate-notes "$(VERSION)" "$(BUILD_DIR)/$(TARBALL)" "$(ROCKSPEC)"

luarocks-upload: check-release-status
	luarocks upload --skip-pack --api-key "$(LUAROCKS_API_KEY)" "$(ROCKSPEC)"

release: test check-release-status
	git tag "$(VERSION)"
	git push --tags
	git push
	$(MAKE) github-release
	$(MAKE) luarocks-upload

endif

$(PREAMBLE): config.lua
	@echo "Generating '$@'"
	@sh -c 'echo $(PREAMBLE_DATA) | base64 -d | $(TOKU_TEMPLATE) -f - -o "$@"'

$(ROCKSPEC): $(PREAMBLE)
	@echo "Generating '$@'"
	@sh -c 'echo $(ROCKSPEC_DATA) | base64 -d | $(TOKU_TEMPLATE) -f - -o "$@"'

$(LUAROCKS_MK): $(PREAMBLE)
	@echo "Generating '$@'"
	@sh -c 'echo $(LUAROCKS_MK_DATA) | base64 -d | $(TOKU_TEMPLATE) -f - -o "$@"'

$(LIB_MK): $(PREAMBLE)
	@echo "Generating '$@'"
	@sh -c 'echo $(LIB_MK_DATA) | base64 -d | $(TOKU_TEMPLATE) -f - -o "$@"'

$(BIN_MK): $(PREAMBLE)
	@echo "Generating '$@'"
	@sh -c 'echo $(BIN_MK_DATA) | base64 -d | $(TOKU_TEMPLATE) -f - -o "$@"'

$(TEST_LIB_MK): $(PREAMBLE)
	@echo "Generating '$@'"
	@sh -c 'echo $(LIB_MK_DATA) | base64 -d | $(TOKU_TEMPLATE_TEST) -f - -o "$@"'

$(TEST_BIN_MK): $(PREAMBLE)
	@echo "Generating '$@'"
	@sh -c 'echo $(BIN_MK_DATA) | base64 -d | $(TOKU_TEMPLATE_TEST) -f - -o "$@"'

$(TEST_ROCKSPEC): $(PREAMBLE)
	@echo "Generating '$@'"
	@sh -c 'echo $(ROCKSPEC_DATA) | base64 -d | $(TOKU_TEMPLATE_TEST) -f - -o "$@"'

$(TEST_LUAROCKS_CFG):
	@echo "Generating '$@'"
	@sh -c 'echo $(TEST_LUAROCKS_CFG_DATA) | base64 -d | $(TOKU_TEMPLATE_TEST) -f - -o "$@"'

$(TEST_LUAROCKS_MK): $(PREAMBLE)
	@echo "Generating '$@'"
	@sh -c 'echo $(LUAROCKS_MK_DATA) | base64 -d | $(TOKU_TEMPLATE_TEST) -f - -o "$@"'

$(TEST_LUACOV_CFG): $(PREAMBLE)
	@echo "Generating '$@'"
	@sh -c 'echo $(TEST_LUACOV_DATA) | base64 -d | $(TOKU_TEMPLATE_TEST) -f - -o "$@"'

$(TEST_LUACHECK_CFG): $(PREAMBLE)
	@echo "Generating '$@'"
	@sh -c 'echo $(TEST_LUACHECK_DATA) | base64 -d | $(TOKU_TEMPLATE_TEST) -f - -o "$@"'

$(TEST_ENV): $(PREAMBLE)
	@echo "Generating '$@'"
	@echo "export LUA=\"$(shell $(TEST_LUAROCKS) config lua_interpreter)\"" > "$@"
	@echo "export LUA_PATH=\"$(shell $(TEST_LUAROCKS) path --lr-path);?.lua\"" >> "$@"
	@echo "export LUA_CPATH=\"$(shell $(TEST_LUAROCKS) path --lr-cpath)\"" >> "$@"

$(BUILD_DIR)/%: %
	@case "$<" in \
		res/*) \
			echo "Copying '$<' -> '$@'"; \
			mkdir -p "$(dir $@)"; \
			cp "$<" "$@";; \
		test/res/*) \
			echo "Copying '$<' -> '$@'"; \
			mkdir -p "$(dir $@)"; \
			cp "$<" "$@";; \
		*) \
			echo "Templating '$<' -> '$@'"; \
			$(TOKU_TEMPLATE) -f "$<" -o "$@";; \
	esac

$(BUILD_DIR)/test/%: %
	@case "$<" in \
		res/*) \
			echo "Copying '$<' -> '$@'"; \
			mkdir -p "$(dir $@)"; \
			cp "$<" "$@";; \
		test/res/*) \
			echo "Copying '$<' -> '$@'"; \
			mkdir -p "$(dir $@)"; \
			cp "$<" "$@";; \
		*) \
			echo "Templating '$<' -> '$@'"; \
			$(TOKU_TEMPLATE) -f "$<" -o "$@";; \
	esac

-include $(shell find $(BUILD_DIR) -regex ".*/deps/.*/.*" -prune -o -name "*.d" -print 2>/dev/null)

.PHONY: all test iterate install release check-release-status github-release luarocks-upload
.DEFAULT_GOAL: all
