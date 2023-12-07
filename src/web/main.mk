<%
	sys = require("santoku.system")
	gen = require("santoku.gen")
%>

ifndef OPENRESTY_DIR
$(error OPENRESTY_DIR not set. Exiting!)
endif

export TOKU_TEMPLATE_SERVER = SERVER=1 $(TOKU_TEMPLATE)
export TOKU_TEMPLATE_CLIENT = CLIENT=1 $(TOKU_TEMPLATE)

export CLIENT_VARS = CC="emcc" CXX="em++" AR="emar" LD="emcc" NM="llvm-nm" LDSHARED="emcc" RANLIB="emranlib"

SHARED_LIBS = $(shell find shared/lib -type f 2>/dev/null)

SERVER_DEPS = $(shell find server/deps -type f 2>/dev/null)
SERVER_SCRIPTS = $(shell find server/scripts -type f 2>/dev/null)
SERVER_LIBS = $(shell find server/lib -type f 2>/dev/null)
SERVER_RES = $(shell find server/res -type f 2>/dev/null)

CLIENT_DEPS = $(shell find client/deps -type f 2>/dev/null)
CLIENT_PAGES = $(shell find client/pages -type f 2>/dev/null)
CLIENT_LIBS = $(shell find client/lib -type f 2>/dev/null)
CLIENT_STATIC = $(shell find client/static -type f 2>/dev/null)
CLIENT_RES = $(shell find client/res -type f 2>/dev/null)

SERVER_LUAROCKS_CFG = $(BUILD_DIR)/server/luarocks.lua
CLIENT_LUAROCKS_CFG = $(BUILD_DIR)/client/luarocks.lua

export SERVER_LUAROCKS = LUAROCKS_CONFIG=$(SERVER_LUAROCKS_CFG) luarocks
export CLIENT_LUAROCKS = LUAROCKS_CONFIG=$(CLIENT_LUAROCKS_CFG) luarocks

SERVER_MK = $(BUILD_DIR)/server/server.mk
SERVER_LUAROCKS_MK = $(BUILD_DIR)/server/luarocks.mk

CLIENT_MK = $(BUILD_DIR)/client/client.mk
CLIENT_LUAROCKS_MK = $(BUILD_DIR)/client/luarocks.mk

LUACHECK_CFG = $(BUILD_DIR)/luacheck.lua

CONFIG_DEPS += $(lastword $(MAKEFILE_LIST))
CONFIG_DEPS += $(SERVER_LUAROCKS_CFG) $(CLIENT_LUAROCKS_CFG)
CONFIG_DEPS += $(SERVER_LUAROCKS_MK) $(CLIENT_LUAROCKS_MK)
CONFIG_DEPS += $(SERVER_MK) $(CLIENT_MK) $(LUACHECK_CFG)
CONFIG_DEPS += $(addprefix $(BUILD_DIR)/, $(SERVER_DEPS) $(SERVER_SCRIPTS) $(SERVER_LIBS) $(SERVER_RES))
CONFIG_DEPS += $(addprefix $(BUILD_DIR)/, $(CLIENT_DEPS) $(CLIENT_PAGES) $(CLIENT_LIBS) $(CLIENT_STATIC) $(CLIENT_RES))
CONFIG_DEPS += $(patsubst shared/%, $(BUILD_DIR)/server/%, $(SHARED_LIBS))
CONFIG_DEPS += $(patsubst shared/%, $(BUILD_DIR)/client/%, $(SHARED_LIBS))

ifndef CLIENT_LUA_DIR
CLIENT_LUA_OK = $(BUILD_DIR)/client/lua.ok
export CLIENT_LUA_DIR = $(BUILD_DIR)/client/lua-5.1.5
CONFIG_DEPS += $(CLIENT_LUA_OK)
$(CLIENT_LUA_OK):
	[ ! -f $(BUILD_DIR)/client/lua-5.1.5.tar.gz ] && \
		cd $(BUILD_DIR)/client && wget https://www.lua.org/ftp/lua-5.1.5.tar.gz || true
	rm -rf $(BUILD_DIR)/client/lua-5.1.5
	cd $(BUILD_DIR)/client && tar xf lua-5.1.5.tar.gz
	cd $(BUILD_DIR)/client/lua-5.1.5 && make generic $(CLIENT_VARS) AR="emar rcu" MYLDFLAGS="$(LDFLAGS) -sSINGLE_FILE -sEXIT_RUNTIME=1"
	cd $(BUILD_DIR)/client/lua-5.1.5 && make local $(CLIENT_VARS) AR="emar rcu" MYLDFLAGS="$(LDFLAGS) -sSINGLE_FILE -sEXIT_RUNTIME=1"
	cd $(BUILD_DIR)/client/lua-5.1.5/bin && mv lua lua.js
	cd $(BUILD_DIR)/client/lua-5.1.5/bin && mv luac luac.js
	cd $(BUILD_DIR)/client/lua-5.1.5/bin && printf "#!/bin/sh\nnode \"\$$(dirname \$$0)/lua.js\" \"\$$@\"\n" > lua && chmod +x lua
	cd $(BUILD_DIR)/client/lua-5.1.5/bin && printf "#!/bin/sh\nnode \"\$$(dirname \$$0)/luac.js\" \"\$$@\"\n" > luac && chmod +x luac
	touch "$@"
endif

ifndef CLIENT_SQLITE_DIR
CLIENT_SQLITE_OK = $(BUILD_DIR)/client/sqlite.ok
CONFIG_DEPS += $(CLIENT_SQLITE_OK)
$(CLIENT_SQLITE_OK):
	@echo TODO: skipping sqlite for now
	touch "$@"
endif

<%
	return gen.ivals(build_excludes or {}):map(function (pat)
		return "CONFIG_DEPS := $(filter-out $(BUILD_DIR)/" .. pat .. ", $(CONFIG_DEPS))"
	end):concat("\n")
%>

all: $(CONFIG_DEPS)
	@echo "Running all"
	cd $(BUILD_DIR)/server && $(MAKE) -f server.mk
	cd $(BUILD_DIR)/client && $(MAKE) -f client.mk

run: $(CONFIG_DEPS) all
	@echo "Running server"
	sh $(DIST_DIR)/run.sh

kill:
	@echo "Killing server"
	killall openresty

test: $(CONFIG_DEPS)
	@echo "Running test"
	$(MAKE) kill || true
	$(MAKE) run

iterate: $(CONFIG_DEPS)
	@echo "Running iterate"
	@while true; do \
		$(MAKE) test; \
		inotifywait -qqr -e close_write -e create -e delete $(filter-out tmp, $(wildcard *)); \
	done

$(SERVER_LUAROCKS_CFG): $(MAIN_CONFIG)
	@echo "Generating '$@'"
	@sh -c 'echo $(LUAROCKS_CFG_DATA) | base64 -d | $(TOKU_TEMPLATE_SERVER) -f - -o "$@"'

$(CLIENT_LUAROCKS_CFG): $(MAIN_CONFIG)
	@echo "Generating '$@'"
	@sh -c 'echo $(LUAROCKS_CFG_DATA) | base64 -d | $(TOKU_TEMPLATE_CLIENT) -f - -o "$@"'

$(SERVER_LUAROCKS_MK): $(MAIN_CONFIG)
	@echo "Generating '$@'"
	@sh -c 'echo $(LUAROCKS_MK_DATA) | base64 -d | $(TOKU_TEMPLATE_SERVER) -f - -o "$@"'

$(CLIENT_LUAROCKS_MK): $(MAIN_CONFIG)
	@echo "Generating '$@'"
	@sh -c 'echo $(LUAROCKS_MK_DATA) | base64 -d | $(TOKU_TEMPLATE_CLIENT) -f - -o "$@"'

$(LUACHECK_CFG): $(MAIN_CONFIG)
	@echo "Generating '$@'"
	@sh -c 'echo $(LUACHECK_DATA) | base64 -d | $(TOKU_TEMPLATE) -f - -o "$@"'

$(SERVER_MK): $(MAIN_CONFIG)
	@echo "Generating '$@'"
	@sh -c 'echo $(SERVER_MK_DATA) | base64 -d | $(TOKU_TEMPLATE) -f - -o "$@"'

$(CLIENT_MK): $(MAIN_CONFIG)
	@echo "Generating '$@'"
	@sh -c 'echo $(CLIENT_MK_DATA) | base64 -d | $(TOKU_TEMPLATE) -f - -o "$@"'

$(BUILD_DIR)/server/lib/%: shared/lib/%
	@echo "Copying '$<' -> '$@'"
	mkdir -p "$(dir $@)"
	cp "$<" "$@"

$(BUILD_DIR)/client/lib/%: shared/lib/%
	@echo "Copying '$<' -> '$@'"
	mkdir -p "$(dir $@)"
	cp "$<" "$@"

$(BUILD_DIR)/%: %
	@case "$<" in \
		res/*) \
			echo "Copying '$<' -> '$@'"; \
			mkdir -p "$(dir $@)"; \
			cp "$<" "$@";; \
		server/res/*) \
			echo "Copying '$<' -> '$@'"; \
			mkdir -p "$(dir $@)"; \
			cp "$<" "$@";; \
		client/res/*) \
			echo "Copying '$<' -> '$@'"; \
			mkdir -p "$(dir $@)"; \
			cp "$<" "$@";; \
		*) \
			echo "Templating '$<' -> '$@'"; \
			$(TOKU_TEMPLATE) -f "$<" -o "$@";; \
	esac

-include $(shell find $(BUILD_DIR) -regex "$(BUILD_DIR)/dist/.*" -prune -o -regex ".*/deps/.*/.*" -prune -o -name "*.d" -print 2>/dev/null)

.PHONY: all run kill test iterate
