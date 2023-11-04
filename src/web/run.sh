#!/bin/bash

<%
  gen = require("santoku.gen")
  str = require("santoku.string")
  vec = require("santoku.vector")
  server = server or {}
%>

set -ex
set -o pipefail
cd "$(dirname $0)"

<% return vec.wrap(server.run_envs or {}):extend(str.split(os.getenv("RUN_ENVS") or "")):map(function (env)
  return ". " .. env
end):concat("\n") %>

openresty -c "nginx.conf" -p "$PWD" -e error.log
