#!/bin/sh

<%
  gen = require("santoku.gen")
  str = require("santoku.string")
  vec = require("santoku.vector")
%>

. ./lua.env

<% return vec.wrap(test_envs or {}):extend(str.split(os.getenv("TEST_ENVS") or "")):filter(function (fp)
  return not str.isempty(fp)
end):map(function (env)
  return ". " .. env
end):concat("\n") %>

rm -f luacov.stats.out luacov.report.out || true

if [ -d spec ]; then
 toku test -i "$LUA -l luacov" --match "^.*%.lua$" spec
fi

if [ -f luacov.lua ]; then
  luacov -c luacov.lua
fi

if [ -f luacov.report.out ]; then
  cat luacov.report.out | awk '/^Summary/ { P = NR } P && NR > P + 1'
fi

echo

if [ -f luacheck.lua ]; then
  luacheck --config luacheck.lua $(find lib bin spec -maxdepth 0 2>/dev/null)
fi

echo
