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

if [ -n "$TEST_CMD" ]; then

  set -x
  cd "$ROOT_DIR"
  $TEST_CMD

else

  rm -f luacov.stats.out luacov.report.out || true

  <% template:push(os.getenv(variable_prefix .. "_WASM") == "1") %>

    if [ -n "$TEST" ]; then
      TEST="spec-bundled/${TEST#test/spec/}"
      TEST="${TEST%.lua}"
      toku test -s -i "node --expose-gc" "$TEST"
      status=$?
    elif [ -d spec-bundled ]; then
      toku test -s -i "node --expose-gc" spec-bundled
      status=$?
    fi

  <% template:pop():push(os.getenv(variable_prefix .. "_WASM") ~= "1") %>

    if [ -n "$TEST" ]; then
      TEST="${TEST#test/}"
      toku test -s -i "$LUA -l luacov" "$TEST"
      status=$?
    elif [ -d spec ]; then
      toku test -s -i "$LUA -l luacov" --match "^.*%.lua$" spec
      status=$?
    fi

  <% template:pop() %>

  if [ "$status" = "0" ] && type luacov 2>/dev/null && [ -f luacov.stats.out ] && [ -f luacov.lua ]; then
    luacov -c luacov.lua
  fi

  if [ "$status" = "0" ] && [ -f luacov.report.out ]; then
    cat luacov.report.out | awk '/^Summary/ { P = NR } P && NR > P + 1'
  fi

  echo

  if type luacheck 2>/dev/null && [ -f luacheck.lua ]; then
    luacheck --config luacheck.lua $(find lib bin spec -maxdepth 0 2>/dev/null)
  fi

  echo

fi
