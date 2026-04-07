-- Small helpers shared by plugin specs
local M = {}

--- Keymap rhs that opens a snacks picker
---@param source string
function M.pick(source)
  return function()
    Snacks.picker[source]()
  end
end

return M
