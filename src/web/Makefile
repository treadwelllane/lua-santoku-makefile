<% sys = require("santoku.system") %>

ROOT_DIR = $(PWD)
BUILD_BASE_DIR = $(ROOT_DIR)/.build
PREAMBLE = $(BUILD_BASE_DIR)/preamble.mk

include $(PREAMBLE)

ifndef $(VPFX)_ENV
export $(VPFX)_ENV = default
endif

BUILD_DIR = $(BUILD_BASE_DIR)/$($(VPFX)_ENV)
DIST_DIR = $(BUILD_DIR)/dist

ifndef OPENRESTY_DIR
$(error OPENRESTY_DIR not set. Exiting!)
endif

TOKU_TEMPLATE = BUILD_DIR="$(BUILD_DIR)" DIST_DIR="$(DIST_DIR)" toku template -M -c config.lua
TOKU_TEMPLATE_SERVER = SERVER=1 OPENRESTY_DIR="$(OPENRESTY_DIR)" $(TOKU_TEMPLATE)
TOKU_TEMPLATE_CLIENT = CLIENT=1 CLIENT_LUA_DIR="$(CLIENT_LUA_DIR)" $(TOKU_TEMPLATE)

SERVER_ROCKSPEC = $(BUILD_DIR)/server/$(NAME)-server-$(VERSION).rockspec
CLIENT_ROCKSPEC = $(BUILD_DIR)/client/$(NAME)-client-$(VERSION).rockspec

SHARED_LIBS = $(shell find shared/lib -type f 2>/dev/null)

SERVER_SCRIPTS = $(shell find server/scripts -type f 2>/dev/null)
SERVER_LIBS = $(shell find server/lib -type f 2>/dev/null)
SERVER_RES = $(shell find server/res -type f 2>/dev/null)
SERVER_NGINX_CONF = $(BUILD_DIR)/nginx.conf
SERVER_RUN_SH = $(BUILD_DIR)/run.sh

CLIENT_PAGES = $(shell find client/pages -type f 2>/dev/null)
CLIENT_LIBS = $(shell find client/lib -type f 2>/dev/null)
CLIENT_STATIC = $(shell find client/static -type f 2>/dev/null)
CLIENT_RES = $(shell find client/res -type f 2>/dev/null)

CLIENT_VARS = CC="emcc" CXX="em++" AR="emar" LD="emcc" NM="llvm-nm" LDSHARED="emcc" RANLIB="emranlib"

SERVER_LUAROCKS_CFG = $(BUILD_DIR)/server/luarocks.lua
CLIENT_LUAROCKS_CFG = $(BUILD_DIR)/client/luarocks.lua

SERVER_LUAROCKS = LUAROCKS_CONFIG=$(SERVER_LUAROCKS_CFG) luarocks
CLIENT_LUAROCKS = LUAROCKS_CONFIG=$(CLIENT_LUAROCKS_CFG) luarocks

SERVER_LUAROCKS_MK = $(BUILD_DIR)/server/Makefile
CLIENT_LUAROCKS_MK = $(BUILD_DIR)/client/Makefile

LUACHECK_CFG = $(BUILD_DIR)/luacheck.lua

PREAMBLE_DATA = <% return check(sys.sh("base64 -w0 < src/web/preamble.mk")):co():head() %>
ROCKSPEC_DATA = <% return check(sys.sh("base64 -w0 < src/web/template.rockspec")):co():head() %>
LUAROCKS_CFG_DATA = <% return check(sys.sh("base64 -w0 < src/web/luarocks.lua")):co():head() %>
LUACHECK_DATA = <% return check(sys.sh("base64 -w0 < src/web/luacheck.lua")):co():head() %>
SERVER_NGINX_CONF_DATA = <% return check(sys.sh("base64 -w0 < src/web/nginx.conf")):co():head() %>
SERVER_RUN_SH_DATA = <% return check(sys.sh("base64 -w0 < src/web/run.sh")):co():head() %>
LUAROCKS_MK_DATA = <% return check(sys.sh("base64 -w0 < src/web/luarocks.mk")):co():head() %>

CONFIG_DEPS = $(lastword $(MAKEFILE_LIST))
CONFIG_DEPS += $(SERVER_LUAROCKS_CFG) $(CLIENT_LUAROCKS_CFG)
CONFIG_DEPS += $(SERVER_ROCKSPEC) $(CLIENT_ROCKSPEC) $(SERVER_LUAROCKS_MK) $(CLIENT_LUAROCKS_MK)
CONFIG_DEPS += $(LUACHECK_CFG)
CONFIG_DEPS += $(addprefix $(BUILD_DIR)/, $(SERVER_SCRIPTS) $(SERVER_LIBS) $(SERVER_RES))
CONFIG_DEPS += $(addprefix $(BUILD_DIR)/, $(CLIENT_PAGES) $(CLIENT_LIBS) $(CLIENT_STATIC) $(CLIENT_RES))
CONFIG_DEPS += $(patsubst shared/%, $(BUILD_DIR)/server/%, $(SHARED_LIBS))
CONFIG_DEPS += $(patsubst shared/%, $(BUILD_DIR)/client/%, $(SHARED_LIBS))
CONFIG_DEPS += $(patsubst server/%, $(DIST_DIR)/%, $(SERVER_SCRIPTS) $(SERVER_RES))
CONFIG_DEPS += $(patsubst client/static/%, $(DIST_DIR)/public/%, $(CLIENT_STATIC))
CONFIG_DEPS += $(patsubst client/res/%, $(DIST_DIR)/public/%, $(CLIENT_RES))
CONFIG_DEPS += $(SERVER_NGINX_CONF) $(SERVER_RUN_SH)
CONFIG_DEPS += $(patsubst $(BUILD_DIR)/%, $(DIST_DIR)/%, $(SERVER_NGINX_CONF) $(SERVER_RUN_SH))
# TODO: $(SERVER_LIBS)  $(CLIENT_LIBS) $(CLIENT_PAGES)

# TODO: Omit in dev
CLIENT_ERUDA_JS = $(DIST_DIR)/public/eruda.js
CONFIG_DEPS += $(CLIENT_ERUDA_JS)

ifndef CLIENT_LUA_DIR
CLIENT_LUA_OK = $(BUILD_DIR)/client/lua.ok
CLIENT_LUA_DIR = $(BUILD_DIR)/client/lua-5.4.6/install
CONFIG_DEPS += $(CLIENT_LUA_OK)
$(CLIENT_LUA_OK):
	[ ! -f $(BUILD_DIR)/client/lua-5.4.6.tar.gz ] && \
		cd $(BUILD_DIR)/client && wget https://www.lua.org/ftp/lua-5.4.6.tar.gz || true
	rm -rf $(BUILD_DIR)/client/lua-5.4.6
	cd $(BUILD_DIR)/client && tar xf lua-5.4.6.tar.gz
	cd $(BUILD_DIR)/client/lua-5.4.6 && make $(CLIENT_VARS) AR="emar rcu" LDFLAGS="$(CFLAGS) -sEXIT_RUNTIME=1"
	cd $(BUILD_DIR)/client/lua-5.4.6 && make local $(CLIENT_VARS) AR="emar rcu" LDFLAGS="$(CFLAGS) -sEXIT_RUNTIME=1"
	cd $(BUILD_DIR)/client/lua-5.4.6/install/bin && mv lua lua.js
	cd $(BUILD_DIR)/client/lua-5.4.6/install/bin && mv luac luac.js
	cd $(BUILD_DIR)/client/lua-5.4.6/install/bin && echo -e "#!/bin/sh\nnode \"\$$(dirname \$$0)/lua.js\" \"\$$@\"" > lua && chmod +x lua
	cd $(BUILD_DIR)/client/lua-5.4.6/install/bin && echo -e "#!/bin/sh\nnode \"\$$(dirname \$$0)/luac.js\" \"\$$@\"" > luac && chmod +x luac
	cd $(BUILD_DIR)/client/lua-5.4.6 && cp src/lua.wasm install/bin/lua.wasm
	cd $(BUILD_DIR)/client/lua-5.4.6 && cp src/luac.wasm install/bin/luac.wasm
	touch "$@"
endif

ifndef CLIENT_SQLITE_DIR
CLIENT_SQLITE_OK = $(BUILD_DIR)/client/sqlite.ok
CONFIG_DEPS += $(CLIENT_SQLITE_OK)
$(CLIENT_SQLITE_OK):
	@echo TODO: skipping sqlite for now
	touch "$@"
endif

all: $(CONFIG_DEPS)
	echo "Running all"
	cd $(BUILD_DIR)/server && $(SERVER_LUAROCKS) make $(SERVER_ROCKSPEC)
	cd $(BUILD_DIR)/client && $(CLIENT_LUAROCKS) make $(CLIENT_ROCKSPEC)

run: all
	@echo "Running server"
	@sh $(DIST_DIR)/run.sh

kill:
	@echo "Killing server"
	@killall openresty

test:
	@echo TODO: test
	@$(MAKE) kill || true
	@$(MAKE) run

iterate:
	@echo "Running iterate"
	@while true; do \
		$(MAKE) test; \
		inotifywait -qqr -e close_write -e create -e delete *; \
	done

$(PREAMBLE): config.lua
	@echo "Generating '$@'"
	@sh -c 'echo $(PREAMBLE_DATA) | base64 -d | $(TOKU_TEMPLATE) -f - -o "$@"'

$(SERVER_ROCKSPEC): $(PREAMBLE)
	@echo "Generating '$@'"
	@sh -c 'echo $(ROCKSPEC_DATA) | base64 -d | $(TOKU_TEMPLATE_SERVER) -f - -o "$@"'

$(CLIENT_ROCKSPEC): $(PREAMBLE)
	@echo "Generating '$@'"
	@sh -c 'echo $(ROCKSPEC_DATA) | base64 -d | $(TOKU_TEMPLATE_CLIENT) -f - -o "$@"'

$(SERVER_LUAROCKS_CFG): $(PREAMBLE)
	@echo "Generating '$@'"
	@sh -c 'echo $(LUAROCKS_CFG_DATA) | base64 -d | $(TOKU_TEMPLATE_SERVER) -f - -o "$@"'

$(CLIENT_LUAROCKS_CFG): $(PREAMBLE)
	@echo "Generating '$@'"
	@sh -c 'echo $(LUAROCKS_CFG_DATA) | base64 -d | $(TOKU_TEMPLATE_CLIENT) -f - -o "$@"'

$(SERVER_LUAROCKS_MK): $(PREAMBLE)
	@echo "Generating '$@'"
	@sh -c 'echo $(LUAROCKS_MK_DATA) | base64 -d | $(TOKU_TEMPLATE_SERVER) -f - -o "$@"'

$(CLIENT_LUAROCKS_MK): $(PREAMBLE)
	@echo "Generating '$@'"
	@sh -c 'echo $(LUAROCKS_MK_DATA) | base64 -d | $(TOKU_TEMPLATE_CLIENT) -f - -o "$@"'

$(LUACHECK_CFG): $(PREAMBLE)
	@echo "Generating '$@'"
	@sh -c 'echo $(LUACHECK_DATA) | base64 -d | $(TOKU_TEMPLATE) -f - -o "$@"'

$(SERVER_NGINX_CONF): $(PREAMBLE)
	@echo "Generating '$@'"
	@sh -c 'echo $(SERVER_NGINX_CONF_DATA) | base64 -d | $(TOKU_TEMPLATE_SERVER) -f - -o "$@"'

$(SERVER_RUN_SH): $(PREAMBLE)
	@echo "Generating '$@'"
	@sh -c 'echo $(SERVER_RUN_SH_DATA) | base64 -d | $(TOKU_TEMPLATE_SERVER) -f - -o "$@"'

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

$(BUILD_DIR)/server/lib/%: shared/lib/%
	@echo "Copying '$<' -> '$@'"
	@mkdir -p "$(dir $@)"
	@cp "$<" "$@"

$(BUILD_DIR)/client/lib/%: shared/lib/%
	@echo "Copying '$<' -> '$@'"
	@mkdir -p "$(dir $@)"
	@cp "$<" "$@"

$(DIST_DIR)/public/%: $(BUILD_DIR)/client/static/%
	@echo "Copying '$<' -> '$@'"
	@mkdir -p "$(dir $@)"
	@cp "$<" "$@"

$(DIST_DIR)/public/%: $(BUILD_DIR)/client/res/%
	@echo "Copying '$<' -> '$@'"
	@mkdir -p "$(dir $@)"
	@cp "$<" "$@"

$(DIST_DIR)/scripts/%: $(BUILD_DIR)/server/scripts/%
	@echo "Copying '$<' -> '$@'"
	@mkdir -p "$(dir $@)"
	@cp "$<" "$@"

$(DIST_DIR)/nginx.conf: $(SERVER_NGINX_CONF)
	@echo "Copying '$<' -> '$@'"
	@mkdir -p "$(dir $@)"
	@cp "$<" "$@"

$(DIST_DIR)/run.sh: $(SERVER_RUN_SH)
	@echo "Copying '$<' -> '$@'"
	@mkdir -p "$(dir $@)"
	@cp "$<" "$@"

$(CLIENT_ERUDA_JS):
	mkdir -p "$(dir $@)"
	wget http://cdn.jsdelivr.net/npm/eruda -O "$@"

.PHONY: all run kill test iterate
