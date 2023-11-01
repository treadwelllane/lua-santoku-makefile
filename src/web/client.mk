# Top-level:
#   - Render client rockspec
#   - Render server run.sh

# Client-level:
# 	- Note: use config.lua/etc specifying emcc lua_dir, etc. (later)
# 	- Build lua for emscripten (later)
# 	- Bundle pages/* to web-dist/public/*
#   	- LUA_PATH/CPATH set to lua_modules_client, lua_modules_shared
# 	- Install shared rockspec to ./lua_modules_shared (later)
# 	- Install client rockspec to ./lua_modules_client (later)
# 	- Copy res/* to web-dist/public/*
# 	- Copy static/* to web-dist/public/*

all:

.PHONY: all
