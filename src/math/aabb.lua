local mt = {
	__index = {
		merge = function(self, box)
			self.min = self.min:min(box.min)
			self.max = self.max:max(box.max)
		end,
		
		-- expand the AABB enough to include the given vector
		expand = function(self, vector)
			self.min = self.min:min(vector)
			self.max = self.max:max(vector)
		end,

        contains = function(self, vector)
            return vector.x >= min.x and vector.x <= max.x and vector.y >= min.y and vector.y <= max.y
        end
	}
}

function aabb(min, max)
	local box = {
        min = min,
        max = max
    }
    setmetatable(box, mt)
	return box
end
