<% sys = require("santoku.system") %>

all:

-include config.mk

export ROOT_DIR = $(PWD)
export MAIN_CONFIG = $(ROOT_DIR)/config.lua
export BUILD_BASE_DIR = $(ROOT_DIR)/.build
export PREAMBLE = $(BUILD_BASE_DIR)/preamble.mk

include $(PREAMBLE)

ifndef $(VPFX)_ENV
export $(VPFX)_ENV = default
endif

ENV_CONFIG = $(ROOT_DIR)/config.$($(VPFX)_ENV).lua

ifeq ($(wildcard $(ENV_CONFIG)),)
ENV_CONFIG =
endif

export BUILD_DIR = $(BUILD_BASE_DIR)/$($(VPFX)_ENV)
export DIST_DIR = $(BUILD_DIR)/dist

export MAIN_MAKEFILE = $(BUILD_DIR)/main.mk

export TOKU_TEMPLATE = toku template -M -c $(MAIN_CONFIG) $(addprefix -c , $(ENV_CONFIG))

CLIENT_MK_DATA = <% return check(sys.sh("sh", "-c", "base64 -w0 < src/web/client.mk")):co():head() %>
LUACHECK_DATA = <% return check(sys.sh("sh", "-c", "base64 -w0 < src/web/luacheck.lua")):co():head() %>
LUAROCKS_CFG_DATA = <% return check(sys.sh("sh", "-c", "base64 -w0 < src/web/luarocks.lua")):co():head() %>
LUAROCKS_MK_DATA = <% return check(sys.sh("sh", "-c", "base64 -w0 < src/web/luarocks.mk")):co():head() %>
MAIN_MAKEFILE_DATA = <% return check(sys.sh("sh", "-c", "base64 -w0 < src/web/main.mk")):co():head() %>
PREAMBLE_DATA = <% return check(sys.sh("sh", "-c", "base64 -w0 < src/web/preamble.mk")):co():head() %>
SERVER_MK_DATA = <% return check(sys.sh("sh", "-c", "base64 -w0 < src/web/server.mk")):co():head() %>

export ROCKSPEC_DATA = <% return check(sys.sh("sh", "-c", "base64 -w0 < src/web/template.rockspec")):co():head() %>
export SERVER_NGINX_CONF_DATA = <% return check(sys.sh("sh", "-c", "base64 -w0 < src/web/nginx.conf")):co():head() %>
export SERVER_RUN_SH_DATA = <% return check(sys.sh("sh", "-c", "base64 -w0 < src/web/run.sh")):co():head() %>

$(PREAMBLE): $(MAIN_CONFIG)
	@echo "Generating '$@'"
	@sh -c 'echo $(PREAMBLE_DATA) | base64 -d | $(TOKU_TEMPLATE) -f - -o "$@"'

$(MAIN_MAKEFILE): $(MAIN_CONFIG)
	@echo "Generating '$@'"
	@sh -c 'echo $(MAIN_MAKEFILE_DATA) | base64 -d | $(TOKU_TEMPLATE) -f - -o "$@"'

include $(MAIN_MAKEFILE)
