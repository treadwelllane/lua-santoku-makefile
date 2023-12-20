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

ifdef $(VPFX)_WASM
export $(VPFX)_WASM
export CLIENT_VARS = CC="emcc" CXX="em++" AR="emar" LD="emcc" NM="llvm-nm" LDSHARED="emcc" RANLIB="emranlib"
export BUILD_DIR = $(BUILD_BASE_DIR)/$($(VPFX)_ENV)-wasm
export CC = emcc
export CXX = em++
export AR = emar
export NM = llvm-nm
export LDSHARED = emcc
export RANLIB = emranlib
else
export BUILD_DIR = $(BUILD_BASE_DIR)/$($(VPFX)_ENV)
endif

export $(VPFX)_PROFILE

TOKU_TEMPLATE = BUILD_DIR="$(BUILD_DIR)" toku template -M -c $(ROOT_DIR)/config.lua
export TOKU_TEMPLATE_TEST = TEST=1 $(TOKU_TEMPLATE)
ROCKSPEC = $(BUILD_DIR)/$(NAME)-$(VERSION).rockspec

LIB = $(shell find lib -type f 2>/dev/null)
BIN = $(shell find bin -type f 2>/dev/null)
TEST_SPEC = $(shell find test/spec -type f 2>/dev/null)
TEST_OTHER = $(filter-out $(TEST_SPEC), $(shell find test -type f 2>/dev/null))
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
export TEST_LUAROCKS = LUAROCKS_CONFIG=$(TEST_LUAROCKS_CFG) luarocks
TEST_LUAROCKS_CFG = $(BUILD_DIR)/test/luarocks.lua
TEST_LUAROCKS_MK = $(BUILD_DIR)/test/Makefile
TEST_ENV = $(BUILD_DIR)/test/lua.env
export TEST_LUACOV_CFG = $(BUILD_DIR)/test/luacov.lua
export TEST_LUACOV_STATS_FILE = $(BUILD_DIR)/test/luacov.stats.out
export TEST_LUACOV_REPORT_FILE = $(BUILD_DIR)/test/luacov.report.out
TEST_LUACHECK_CFG = $(BUILD_DIR)/test/luacheck.lua

PREAMBLE_DATA = <% return check(sys.sh("sh", "-c", "base64 -w0 < src/basic/preamble.mk")):co():head() %>
ROCKSPEC_DATA = <% return check(sys.sh("sh", "-c", "base64 -w0 < src/basic/template.rockspec")):co():head() %>

LUAROCKS_MK_DATA = <% return check(sys.sh("sh", "-c", "base64 -w0 < src/basic/luarocks.mk")):co():head() %>

LIB_MK_DATA = <% return check(sys.sh("sh", "-c", "base64 -w0 < src/basic/lib.mk")):co():head() %>
BIN_MK_DATA = <% return check(sys.sh("sh", "-c", "base64 -w0 < src/basic/bin.mk")):co():head() %>

TEST_LUAROCKS_CFG_DATA = <% return check(sys.sh("sh", "-c", "base64 -w0 < src/basic/luarocks.lua")):co():head() %>
TEST_LUACOV_DATA = <% return check(sys.sh("sh", "-c", "base64 -w0 < src/basic/luacov.lua")):co():head() %>
TEST_LUACHECK_DATA = <% return check(sys.sh("sh", "-c", "base64 -w0 < src/basic/luacheck.lua")):co():head() %>

export TEST_RUN_SH_DATA = <% return check(sys.sh("sh", "-c", "base64 -w0 < src/basic/test-run.sh")):co():head() %>

CONFIG_DEPS = $(lastword $(MAKEFILE_LIST))
CONFIG_DEPS += $(ROCKSPEC) $(LUAROCKS_MK) $(LIB_MK) $(BIN_MK)
CONFIG_DEPS += $(TEST_ROCKSPEC) $(TEST_LUAROCKS_MK) $(TEST_LIB_MK) $(TEST_BIN_MK) $(TEST_LUAROCKS_CFG)
CONFIG_DEPS += $(TEST_ENV) $(TEST_LUACOV_CFG) $(TEST_LUACHECK_CFG)
CONFIG_DEPS += $(addprefix $(BUILD_DIR)/, $(LIB) $(BIN) $(RES) $(DEPS))
CONFIG_DEPS += $(addprefix $(BUILD_DIR)/test/, $(LIB) $(BIN) $(RES) $(DEPS))

ifeq ($($(VPFX)_WASM),1)
CONFIG_DEPS += $(addprefix $(BUILD_DIR)/, $(TEST_SPEC) $(TEST_OTHER))
export WASM_TESTS = $(patsubst test/spec/%.lua,$(BUILD_DIR)/test/spec-bundled/%, $(TEST_SPEC))
else
CONFIG_DEPS += $(addprefix $(BUILD_DIR)/, $(TEST_SPEC) $(TEST_OTHER))
endif

TARBALL = $(TARBALL_DIR).tar.gz
TARBALL_DIR = $(NAME)-$(VERSION)
TARBALL_SRCS = Makefile lib/Makefile bin/Makefile $(shell find lib bin deps res -type f 2>/dev/null)

ifeq ($($(VPFX)_WASM),1)
CLIENT_LUA_OK = $(BUILD_DIR)/lua.ok
export CLIENT_LUA_DIR = $(BUILD_DIR)/lua-5.1.5
CONFIG_DEPS := $(CLIENT_LUA_OK) $(CONFIG_DEPS)
$(CLIENT_LUA_OK):
	mkdir -p $(BUILD_DIR)
	[ ! -f $(BUILD_DIR)/lua-5.1.5.tar.gz ] && \
		cd $(BUILD_DIR) && wget https://www.lua.org/ftp/lua-5.1.5.tar.gz || true
	rm -rf $(BUILD_DIR)/lua-5.1.5
	cd $(BUILD_DIR) && tar xf lua-5.1.5.tar.gz
	# TODO: we should  only link nodefs.js and noderawfs.js for the version of lua
	# we're running on the cli, not the version linked to the output programs,
	# right?
	cd $(BUILD_DIR)/lua-5.1.5 && make generic $(CLIENT_VARS) AR="emar rcu" MYLDFLAGS="$(LDFLAGS) -sSINGLE_FILE -sEXIT_RUNTIME=1 -lnodefs.js -lnoderawfs.js"
	cd $(BUILD_DIR)/lua-5.1.5 && make local $(CLIENT_VARS) AR="emar rcu" MYLDFLAGS="$(LDFLAGS) -sSINGLE_FILE -sEXIT_RUNTIME=1 -lnodefs.js -lnoderawfs.js"
	cd $(BUILD_DIR)/lua-5.1.5/bin && mv lua lua.js
	cd $(BUILD_DIR)/lua-5.1.5/bin && mv luac luac.js
	cd $(BUILD_DIR)/lua-5.1.5/bin && printf "#!/bin/sh\nnode \"\$$(dirname \$$0)/lua.js\" \"\$$@\"\n" > lua && chmod +x lua
	cd $(BUILD_DIR)/lua-5.1.5/bin && printf "#!/bin/sh\nnode \"\$$(dirname \$$0)/luac.js\" \"\$$@\"\n" > luac && chmod +x luac
	touch "$@"
endif

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

test-luarocks: $(CONFIG_DEPS)
	$(TEST_LUAROCKS) $(ARGS)

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

.PHONY: all test iterate install release check-release-status github-release luarocks-upload test-luarocks
