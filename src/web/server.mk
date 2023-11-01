# Top-level:
#   - Render server rockspec
#   - Render server run.sh
#   	- LUA_PATH/CPATH set to modules, lua_modules_server, lua_modules_shared

# Server-level:
# 	- Note: use config.lua specifying openresty luajit lua_dir, etc.
# 	- Source shared deps (later)
# 	- Build & source server deps (later)
# 	- Install shared rockspec to web-dist/lua_modules_shared
# 	- Install server rockspec to web-dist/lua_modules_server
# 	- Copy scripts/* to web-dist/scripts/*
# 	- Copy nginx.conf to web-dist/nginx.conf

all:

.PHONY: all
