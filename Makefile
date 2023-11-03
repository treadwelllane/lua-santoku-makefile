all: dist/basic/Makefile dist/basic/config.lua dist/web/Makefile dist/web/config.lua

iterate:
	@while true; do \
		$(MAKE); \
		inotifywait -qqr -e close_write -e create -e delete *; \
	done

dist/basic/Makefile: $(shell find src/basic -type f)
	toku template -f src/basic/Makefile -o $@

dist/basic/config.lua: src/basic/config.lua
	install -m 644 src/basic/config.lua $@

dist/web/Makefile: $(shell find src/web -type f)
	toku template -f src/web/Makefile -o $@

dist/web/config.lua: src/web/config.lua
	install -m 644 src/web/config.lua $@

clean:
	rm -rf dist

.PHONY: all iterate clean
