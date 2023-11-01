all:
	@if [ -d server ]; then $(MAKE) -C server; fi
	@if [ -d client ]; then $(MAKE) -C client; fi

.PHONY: all
