export VPFX = <% return variable_prefix %>

include $(addprefix ../, $(PARENT_DEPS_RESULTS))

LIB_LUA = $(shell find * -name '*.lua')
LIB_C = $(shell find * -name '*.c')
LIB_O = $(LIB_C:.c=.o)
LIB_SO = $(LIB_O:.o=.$(LIB_EXTENSION))

INST_LUA = $(addprefix $(INST_LUADIR)/, $(LIB_LUA))
INST_SO = $(addprefix $(INST_LIBDIR)/, $(LIB_SO))

LIB_CFLAGS += -Wall $(addprefix -I, $(LUA_INCDIR))
LIB_LDFLAGS += -Wall $(addprefix -L, $(LUA_LIBDIR))

<% template:push(os.getenv("TEST") == "1") %>

ifeq ($($(VPFX)_SANITIZE),1)
LIB_CFLAGS += -fsanitize=address -fsanitize=leak
LIB_LDFLAGS += -fsanitize=address -fsanitize=leak
endif

<% template:pop() %>

all: $(LIB_O) $(LIB_SO)

%.o: %.c
	$(CC) $(LIB_CFLAGS) $(CFLAGS) -c -o $@ $<

%.$(LIB_EXTENSION): %.o
	$(CC) $(CFLAGS) $(LIB_LDFLAGS) $(LDFLAGS) $(LIBFLAG) -o $@ $<

install: $(INST_LUA) $(INST_SO)

$(INST_LUADIR)/%.lua: ./%.lua
	mkdir -p $(dir $@)
	cp $< $@

$(INST_LIBDIR)/%.$(LIB_EXTENSION): ./%.$(LIB_EXTENSION)
	mkdir -p $(dir $@)
	cp $< $@

.PHONY: all install
