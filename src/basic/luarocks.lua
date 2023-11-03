<% template:push(os.getenv("TEST") == "1") %>

rocks_trees = {
  { name = "system",
    root = "<% return os.getenv('BUILD_DIR') %>/test/lua_modules"
  } }

<% template:pop():push(os.getenv("TEST") ~= "1") %>

rocks_trees = {
  { name = "system",
    root = "<% return os.getenv('BUILD_DIR') %>/lua_modules"
  } }

<% template:pop() %>
