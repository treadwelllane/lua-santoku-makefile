#!/bin/sh

<%
  str = require("santoku.string")
  vec = require("santoku.vector")
  server = server or {}
%>

set -ex
cd "$(dirname $0)"

<% return vec.wrap(server.run_envs or {}):extend(str.split(os.getenv("RUN_ENVS") or ""))
  :filter(function (env)
    return not str.isempty(env)
  end)
  :map(function (env)
    return ". " .. env
  end):concat("\n") %>

mkdir -p logs
touch logs/error.log logs/access.log

if [ "$<% return variable_prefix %>_FG" = "1" ]
then
  tail -qf logs/* &
  exec openresty -p "$PWD" -c nginx.conf
else
  openresty -p "$PWD" -c nginx.conf &
fi
