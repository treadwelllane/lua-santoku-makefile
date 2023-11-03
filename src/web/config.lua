local _ENV = {}

name = "example"
version = "0.0.1-1"

server = {
  dependencies = {
    "lua >= 5.1"
  },
}

client = {
  dependencies = {
    "lua >= 5.1"
  },
}

return { env = _ENV }
