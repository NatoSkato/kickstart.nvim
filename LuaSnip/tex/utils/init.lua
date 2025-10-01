local function add_require_path(dir)
  dir = dir:gsub('\\', '/') -- Normalize
  if not package.path:find(dir, 1, true) then
    package.path = dir .. '/?.lua;' .. package.path
  end
end

add_require_path(tostring(os.getenv 'HOME') .. '/.config/nvim/LuaSnip/tex/utils') -- Linux form
add_require_path(tostring(os.getenv 'UserProfile') .. '\\.config\\nvim\\LuaSnip\\tex\\utils') -- Windows form (normalized automatically)
local M = {}

M.conditions = require 'conditions'
M.scaffolding = require 'scaffolding'

return M
