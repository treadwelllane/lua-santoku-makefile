<%

rocks_root = os.getenv("TEST") == "1"
  and os.getenv("BUILD_DIR") .. "/test/lua_modules"
  or os.getenv("BUILD_DIR") .. "/lua_modules"

is_wasm = os.getenv(variable_prefix .. "_WASM") == "1"

%>

rocks_trees = {
  { name = "system",
    root = "<% return rocks_root %>"
  } }

<% template:push(is_wasm) %>

-- NOTE: Not specifying the interpreter, version, LUA, LUA_BINDIR, and LUA_DIR
-- so that the host lua is used install rocks. The other variables affect how
-- those rocks are built

-- lua_interpreter = "lua"
-- lua_version = "5.1"

variables = {

  -- LUA = "<% return os.getenv('CLIENT_LUA_DIR') %>/bin/lua",
  -- LUA_BINDIR = "<% return os.getenv('CLIENT_LUA_DIR') %>/bin",
  -- LUA_DIR = "<% return os.getenv('CLIENT_LUA_DIR') %>",

  LUALIB = "liblua.a",
  LUA_INCDIR = "<% return os.getenv('CLIENT_LUA_DIR') %>/include",
  LUA_LIBDIR = "<% return os.getenv('CLIENT_LUA_DIR') %>/lib",
  LUA_LIBDIR_FILE = "liblua.a",

  CFLAGS = "-I <% return os.getenv('CLIENT_LUA_DIR') %>/include",
  LDFLAGS = "-L <% return os.getenv('CLIENT_LUA_DIR') %>/lib",
  LIBFLAG = "-shared",

  CC = "emcc",
  CXX = "em++",
  AR = "emar",
  LD = "emcc",
  NM = "llvm-nm",
  LDSHARED = "emcc",
  RANLIB = "emranlib",

}

<% template:pop() %>
