all: dist/Makefile dist/config.lua

iterate:
	@while true; do \
		$(MAKE); \
		inotifywait -qqr -e close_write -e create -e delete *; \
	done

dist/Makefile: src/Makefile src/preamble.mk src/luarocks.mk src/template.rockspec
	toku template -f src/Makefile -o $@

dist/config.lua: src/config.lua
	install src/config.lua $@

.PHONY: all iterate
