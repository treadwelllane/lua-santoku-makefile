# Now

- On release, do a full clean rebuild and test, and cause make to fail
  completely when/if the test fails

- deps/<dep>/Makefile and deps/<dep>/results.mk
- LIB_CFLAGS, etc

- Manually create LUA_PATH and LUA_CPATH for preamble.mk
- Support deps-test that are only built for tests
- Support for testing with emscripten
- Support for testing multiple lua versions
- Support for emscripten-only libraries

- Sanitizers

# Eventually

- Specify order for dependencies
