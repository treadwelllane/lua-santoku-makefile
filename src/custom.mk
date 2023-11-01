build-pre:
	@echo "Running '$@' hook"

build-post:
	@echo "Running '$@' hook"

web-build-pre:
	@echo "Running '$@' hook"

web-build-post:
	@echo "Running '$@' hook"

web-client-build-pre:
	@echo "Running '$@' hook"

web-client-build-post:
	@echo "Running '$@' hook"

web-server-build-pre:
	@echo "Running '$@' hook"

web-server-build-post:
	@echo "Running '$@' hook"

test-pre:
	@echo "Running '$@' hook"

test-post:
	@echo "Running '$@' hook"

.PHONY: build-pre build-post web-build-pre web-build-post web-client-build-pre web-client-build-post web-server-build-pre web-server-build-post test-pre test-post
