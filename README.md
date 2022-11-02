# luajit-ffi-loader
luajit ffi module better loader

## How to use
please require `ffi.loader` at lua vm initialize 
```lua
  require 'ffi.loader'
```

## ffi.load(name,global,find_lua_path)
the function at now will search each `package.cpath` to load shared library

param `name` and `global` is same as default ffi.load
param `find_lua_path` for lookup each package.path
