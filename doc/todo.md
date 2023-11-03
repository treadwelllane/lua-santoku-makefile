# Now

- Web makefiles
- Cleanup

# Later

- Copy deps to LUA_LIBDIR (or wherever is appropriate - LUA_CONFDIR?) so they
  can be accessed at runtime

- Rename src to lib

- On release, do a full clean rebuild and test, and cause make to fail
  completely when/if the test fails
- Shouldn't need to re-install to local lua_modules on release

- Support for testing with emscripten
- Support for testing multiple lua versions
- Support for emscripten-only libraries
- Support deps-test/deps-emscripten/deps-test-emscripten that are only built for
  their corresponding configuration (tests, emscripten, emscripten tests)

- Sanitizers

# Eventually

- Merge web and non-web makefiles
