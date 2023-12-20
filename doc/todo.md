# Now

- Show 0% for untested files

- Allow installing WASM-built executable globally with locally installed
  dependencies

- When VPFX_PROFILE=1 is set, showing profiles requires a re-compile for WASM
  but not for standard builds. Is this desired or changable?

- VPFX_PROFILE=1 and VPFX_WASM=1 doesn't print profiles since the --no-close
  bundler flag results in the profile userdata never getting collected. Can we
  somehow attach the profiler to the string chunk and then invoke the garbage
  collector where lua_close would normally go?

- Allow running tests in all lua versions, including luajit by compiling and
  running locally
- Run both wasm and native tests on make release, allow specifying never wasm or never native
- Don't fail build if luacov module not available
- Luacov doesn't report for WASM builds because of the bundling and loading as
  a string

- Figure out how to enable luac based on existance of luac or if interpreter is
  luajit (with luajit -b). Luac is currently disabled
- When running deps, invoke make results.mk so that results.mk doesn't have to
  be the first target (lots of confusion running "make" and wondering why
  results.mk isn't created, only to realize it isn't the first target)
- Install toku cli, luacov, and luacheck as part of build
- Use-provided temmplates
- Test removal of make -E on mac
- Documentation
- Reduce verbosity (specifically for install/cp)
- Add dev_dependencies (defaults to santoku-cli, luacheck, luacov, but can be
  added to)
- print relative paths where possible
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
