local ffi = require 'ffi'
local string_gmatch = string.gmatch
local string_match = string.match
local old_ffi_load = ffi.load
local _M = {
    is_ios = ffi.os == 'OSX'
}
---@param name string
function _M.loadlib(name, global, cpath)

    local so_name = name
    if name:find("lib") ~= 1 then
        so_name = "lib" .. name
    end
    for k, _ in string_gmatch(cpath, "[^;]+") do
        local so_path = string_match(k, "(.*/)")
        if so_path then
            -- "so_path" could be nil. e.g, the dir path component is "."
            so_path = so_path .. so_name

            -- Don't get me wrong, the only way to know if a file exist is
            -- trying to open it.
            local f = io.open(so_path)
            if f ~= nil then
                io.close(f)
                return ffi.load(so_path, global)
            end
        end
    end
end

local function load(name, global, cpath)
    local lib = _M.loadlib(name, global, cpath)
    if lib then return lib end

    local is_ios = _M.is_ios

    local b = name:find(".so")
    if not b then
        lib = _M.loadlib(name .. '.so', global, cpath)
        if lib then return lib end

        if is_ios then
            lib = _M.loadlib(name .. '.dylib', global, cpath)
            if lib then return lib end
        end
    else
        if is_ios then
            lib = _M.loadlib(name:sub(1, b - 1) .. '.dylib', global, cpath)
            if lib then return lib end
        end
    end
end

---@param name    string
---@param global? boolean
---@param find_lua_path? boolean
---@return ffi.namespace* clib
---@nodiscard
function ffi.load(name, global, find_lua_path)
    local lib = load(name, global, package.cpath)
    if lib then return lib end

    if find_lua_path then
        lib = load(name, global, package.path)
        if lib then return lib end
    end

    return old_ffi_load(name, global)
end

return _M
