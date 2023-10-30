<% vec = require("santoku.vector") %>
<% str = require("santoku.string") %>

include = {
  <% return vec.wrap(luacov_include or {}):map(str.quote):concat(",\n") %>
}
