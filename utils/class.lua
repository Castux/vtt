local class = function()

	local c = {}
	c.__index = c
	c.class = c

	c.new = function(...)

		local obj = {}
		setmetatable(obj,c)

		obj:init(...)

		return obj
	end

	setmetatable(c, {__call = function(t, ...) return c.new(...) end })

	return c
end

return class
