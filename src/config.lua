local _ENV = {}

name = "example"
version = "0.0.1-1"
variable_prefix = "EXAMPLE"

license = "MIT"

luacov_include = {
  -- fixme
}

dependencies = {
  "lua >= 5.1",
}

test_dependencies = {
}

homepage = nil
tarball = nil
download = nil

return { env = _ENV }
