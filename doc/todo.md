# Now

- On release, do a full clean rebuild and test, and cause make to fail
  completely when/if the test fails

- Consider generating even the top-level targets so that we can include/exclude
  targets like release for non-public builds
  - This will require having toku installed, so may be a non-starter

- Consider removing test target/etc from released tarballs since it depends on
  toku and is not necessary

- Web app support
    - Lua client optional
    - Hooks for integrating webpack/etc
    - Sqlite, worker, service worker optional
    - Index.html, worker, etc scaffolding refactored into separate libraries

- Fix for toku templates:
    - A failing "check" call doesn't cause toku
      template to exit with a failed status

- Support for testing with emscripten

- Sanitizers

# Eventually

- Specify order for dependencies
