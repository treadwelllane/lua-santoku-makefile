<%
	sys = require("santoku.system")
	str = require("santoku.string")
	tbl = require("santoku.table")
%>

export VPFX = <% return variable_prefix %>

all:

DEPS_DIRS = $(shell find deps/* -maxdepth 0 -type d 2>/dev/null)
DEPS_RESULTS = $(addsuffix /results.mk, $(DEPS_DIRS))

include $(DEPS_RESULTS)

ROCKSPEC = $(NAME)-server-$(VERSION).rockspec

NGINX_CONF_BUILD = $(BUILD_DIR)/nginx.conf
NGINX_CONF_DIST = $(DIST_DIR)/nginx.conf

RUN_SH_BUILD = $(BUILD_DIR)/run.sh
RUN_SH_DIST = $(DIST_DIR)/run.sh

DEPS = $(ROCKSPEC) $(NGINX_CONF_DIST) $(RUN_SH_DIST)
DEPS += $(addprefix $(DIST_DIR)/, $(shell find scripts res -type f 2>/dev/null))

<% post_luarocks = tbl.get(server, "hooks", "post_luarocks") %>
<% template:push(post_luarocks) %>
POST_LUAROCKS_DATA = <%
	local script = str.quote(post_luarocks)
	return check(sys.sh("sh", "-c", "printf '#!/bin/sh\nset -e\n'" .. script .. " | base64 -w0")):co():head()
%>
DEPS += hooks/post_luarocks.sh
hooks/post_luarocks.sh: $(MAIN_CONFIG)
	@echo "Generating '$@'"
	@sh -c 'echo $(POST_LUAROCKS_DATA) | base64 -d | $(TOKU_TEMPLATE_SERVER) -f - -o "$@"'
<% template:pop() %>

all: $(DEPS) luarocks

luarocks:
	$(SERVER_LUAROCKS) make $(ROCKSPEC)
	<% template:push(post_luarocks) %>
	@cd "$(ROOT_DIR)" && LUAROCKS="$(SERVER_LUAROCKS)" sh $(CURDIR)/hooks/post_luarocks.sh
	<% template:pop() %>

$(ROCKSPEC): $(MAIN_CONFIG)
	@echo "Generating '$@'"
	@sh -c 'echo $(ROCKSPEC_DATA) | base64 -d | $(TOKU_TEMPLATE_SERVER) -f - -o "$@"'

$(NGINX_CONF_BUILD): $(MAIN_CONFIG)
	@echo "Generating '$@'"
	@sh -c 'echo $(SERVER_NGINX_CONF_DATA) | base64 -d | $(TOKU_TEMPLATE_SERVER) -f - -o "$@"'

$(RUN_SH_BUILD): $(MAIN_CONFIG)
	@echo "Generating '$@'"
	@sh -c 'echo $(SERVER_RUN_SH_DATA) | base64 -d | $(TOKU_TEMPLATE_SERVER) -f - -o "$@"'

$(NGINX_CONF_DIST): $(NGINX_CONF_BUILD)
	@echo "Copying '$<' -> '$@'"
	mkdir -p "$(dir $@)"
	cp "$<" "$@"

$(RUN_SH_DIST): $(RUN_SH_BUILD)
	@echo "Copying '$<' -> '$@'"
	mkdir -p "$(dir $@)"
	cp "$<" "$@"
	chmod +x "$@"

$(DIST_DIR)/scripts/%: scripts/%
	@echo "Copying '$<' -> '$@'"
	mkdir -p "$(dir $@)"
	cp "$<" "$@"

deps/%/results.mk: deps/%/Makefile
	@$(MAKE) -C "$(dir $@)"

-include $(shell find $(BUILD_DIR) -regex "$(BUILD_DIR)/dist/.*" -prune -o -regex ".*/deps/.*/.*" -prune -o -name "*.d" -print 2>/dev/null)

.PHONY: all luarocks
