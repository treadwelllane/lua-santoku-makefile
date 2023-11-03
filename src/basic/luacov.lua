<% str = require("santoku.string") %>
<% fs = require("santoku.fs") %>
<% gen = require("santoku.gen") %>
<% vec = require("santoku.vector") %>

<% files = gen.pack("src", "bin"):filter(function (dir)
  return check(fs.exists(dir))
end):map(function (reldir)
  reldir = reldir .. fs.pathdelim
  return fs.files(reldir, { recurse = true }):map(check):filter(function (fp)
    return vec("lua", "c", "cpp"):includes(string.lower(fs.extension(fp)))
  end):pastel(reldir)
end):flatten():map(function (reldir, fp)
  local mod = fs.stripextension(str.stripprefix(fp, reldir)):gsub("/", ".")
  return mod, fp, fs.join(os.getenv("BUILD_DIR"), fp)
end) %>

modules = {
  <% return files:map(function (mod, relpath)
    return str.interp("[\"%mod\"] = \"%relpath\"", { mod = mod, relpath = relpath })
  end):concat(",\n") %>
}

include = {
  <% return files:map(function (_, _, fp)
    return str.interp("\"%fp\"", { fp = fp })
  end):concat(",\n") %>
}
