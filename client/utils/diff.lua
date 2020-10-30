local nilValue = "__nil"

-- Compute the difference between two values
-- Deletions are incidated by the special value nilValue
-- Lack of changes are returned as nil

local function diff(old, new)

	-- Value deletion

	if new == nil then
		return nilValue
	end

	-- New type

	if type(old) ~= type(new) then
		return new
	end

	-- Same type, not table
	-- There is a difference only if the value changed

	if type(new) ~= "table" then
		if new == old then
			return nil
		else
			return new
		end
	end

	-- Table comparison: field by field

	local keys = {}
	local res = {}

	for k,v in pairs(old) do
		keys[k] = true
	end

	for k,v in pairs(new) do
		keys[k] = true
	end

	local someChange = false

	for key in pairs(keys) do
		local d = diff(old[key], new[key])
		res[key] = d
		if d then
			someChange = true
		end
	end

	-- If none of the fields changed, the tables are identical

	if someChange then
		return res
	else
		return nil
	end
end

-- Apply patch in place (keep previous tables when possible)

local function patch(old, diff)

	-- No change

	if diff == nil then
		return old
	end

	-- Deletion

	if diff == nilValue then
		return nil
	end

	-- New value

	if type(diff) ~= "table" then
		return diff
	end

	-- New or updated table value

	if type(old) ~= "table" then
		old = {}
	end

	local keys = {}
	for k,v in pairs(old) do
		keys[k] = true
	end

	for k,v in pairs(diff) do
		keys[k] = true
	end

	for k in pairs(keys) do
		old[k] = patch(old[k], diff[k])
	end

	return old
end


return
{
	nilValue = nilValue,
	diff = diff,
	patch = patch
}
