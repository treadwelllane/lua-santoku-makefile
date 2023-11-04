<%

  str = require("santoku.string")
  vec = require("santoku.vector")

  component = nil

  if os.getenv("CLIENT") == "1" then
    component = "client"
  elseif os.getenv("SERVER") == "1" then
    component = "server"
  end

  if component then
    name = name .. "-" .. component
  end

  server = server or {}
  client = client or {}

  if component == "server" then
    dependencies = server.dependencies
  elseif component == "client" then
    dependencies = client.dependencies
  end

%>

package = "<% return name %>"
version = "<% return version %>"
rockspec_format = "3.0"

source = { url = "" }

dependencies = {
  <% return vec.wrap(dependencies or {}):map(str.quote):concat(",\n") %>
}

build = {
  type = "make",
  makefile = "luarocks.mk",
  variables = {
    LIB_EXTENSION = "$(LIB_EXTENSION)",
  },
  build_variables = {
    CC = "$(CC)",
    CFLAGS = "$(CFLAGS)",
    LIBFLAG = "$(LIBFLAG)",
    LUA_BINDIR = "$(LUA_BINDIR)",
    LUA_INCDIR = "$(LUA_INCDIR)",
    LUA_LIBDIR = "$(LUA_LIBDIR)",
    LUA = "$(LUA)",
  },
  install_variables = {
    INST_PREFIX = "$(PREFIX)",
    INST_BINDIR = "$(BINDIR)",
    INST_LIBDIR = "$(LIBDIR)",
    INST_LUADIR = "$(LUADIR)",
    INST_CONFDIR = "$(CONFDIR)",
  }
}
