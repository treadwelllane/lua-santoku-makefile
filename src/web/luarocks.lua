<% template:push(os.getenv("SERVER") == "1") %>

lua_interpreter = "luajit"
lua_version = "5.1"

rocks_trees = {
  { name = "system",
    root = "<% return os.getenv('DIST_DIR') %>/lua_modules"
  } }

variables = {

  LUA = "<% return os.getenv('OPENRESTY_DIR') %>/luajit/bin/luajit",
  LUALIB = "libluajit-5.1.so",
  LUA_BINDIR = "<% return os.getenv('OPENRESTY_DIR') %>/luajit/bin",
  LUA_DIR = "<% return os.getenv('OPENRESTY_DIR') %>/luajit",
  LUA_INCDIR = "<% return os.getenv('OPENRESTY_DIR') %>/luajit/include/luajit-2.1",
  LUA_LIBDIR = "<% return os.getenv('OPENRESTY_DIR') %>/luajit/lib",

}

<% template:pop():push(os.getenv("CLIENT") == "1") %>

lua_interpreter = "lua"
lua_version = "5.1"

rocks_trees = {
  { name = "system",
    root = "<% return os.getenv('BUILD_DIR') %>/client/lua_modules"
  } }

variables = {

  LUA = "node <% return os.getenv('CLIENT_LUA_DIR') %>/bin/lua",
  LUALIB = "liblua.a",
  LUA_BINDIR = "<% return os.getenv('CLIENT_LUA_DIR') %>/bin",
  LUA_DIR = "<% return os.getenv('CLIENT_LUA_DIR') %>",
  LUA_INCDIR = "<% return os.getenv('CLIENT_LUA_DIR') %>/include",
  LUA_LIBDIR = "<% return os.getenv('CLIENT_LUA_DIR') %>/lib",

  CC = "emcc",
  CXX = "em++",
  AR = "emar",
  LD = "emcc",
  NM = "llvm-nm",
  LDSHARED = "emcc",
  RANLIB = "emranlib",

}

<% template:pop() %>
