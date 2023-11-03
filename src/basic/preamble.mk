NAME = <% return name %>
VERSION = <% return version %>
VPFX = <% return variable_prefix %>

export $(VPFX)_PUBLIC = <% return public and "1" or "0" %>
