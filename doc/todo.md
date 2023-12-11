# Now

- avoid tail in run.sh
- Check if luacov table is working correctly (see santoku-iconv,
  luacov.stats.out doesn't contain any lines for iconv.c but reports hits)
- Use VPFX whenever we're exporting variables
- Don't build client luarocks, lua, etc if no client-side lua
- Don't build nginx, etc if no server-side lua
- Install local santoku-cli, luacov, luacheck as part of build process
- Auto-generate variable prefix from app name by transforming to uppercase and
  converting dashes to underscores
- limit include deps files to well-known project dirs, avoiding deps,
  lua_modules, dist, etc.
- Don't rebuild server/etc when just client/static changes/etc
- Santoku trace in both prod and dev
- Cleanup

# Later

- Copy deps to LUA_LIBDIR (or wherever is appropriate - LUA_CONFDIR?) so they
  can be accessed at runtime

- Shouldn't need to re-install to local lua_modules on release

- Support for testing with emscripten
- Support for testing multiple lua versions
- Support for emscripten-only libraries
- Support deps-test/deps-emscripten/deps-test-emscripten that are only built for
  their corresponding configuration (tests, emscripten, emscripten tests)

- Sanitizers

# Eventually

- Merge web and non-web makefiles
