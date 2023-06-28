-- MathHelper
-- This library helps fixes the atan2 missing in future versions of Lua
local _Math = {}

---@version >5.2
---
---Returns the arc tangent of `y/x` (in radians).
---
---[View documents](command:extension.lua.doc?["en-us/54/manual.html/pdf-math.atan2"])
---
---@param y number
---@param x number
---@return number
function _Math.atan2(y, x)
	if (y < 0 and x < 0) then
		return math.atan(y/ x) - math.pi
	elseif( y > 0 and x < 0) then
		return math.atan(y/x) + math.pi
	else
		return math.atan(y/x)
	end
end

function _Math.clamp(value, min, max)
	return (value < min and min) or (value > max and max) or value 
end
return _Math