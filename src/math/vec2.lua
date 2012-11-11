local mt = {

	__add = function(a, b)
		return vec2(a.x + b.x, a.y + b.y)
	end,
	
	__sub = function(a, b)
		return vec2(a.x - b.x, a.y - b.y)
	end,
	
	__mul = function(a, b)
		if type(b) == "number" then
			return vec2(a.x * b, a.y * b)
		else
			return vec2(a.x * b.x, a.y * b.y)
		end
	end,
	
	__div = function(a, b)
		if type(b) == "number" then
			return vec2(a.x / b, a.y / b)
		else
			return vec2(a.x / b.x, a.y / b.y)
		end
	end,
	
	__unm = function(a)
		return vec2(-a.x, -a.y)
	end,
	
	__eq = function(a, b)
		return a.x == b.x and a.y == b.y
	end,
	
	__lt = function(a, b)
		return a.x < b.x or a.x == b.x and a.y < b.y
	end,
	
	__index = {
		dot = function(self, v)
			return self.x * v.x + self.y * v.y
		end,
		
		perp = function(self)
			return vec2(-self.y, self.x)
		end,
		
		length = function(self)
			return math.sqrt(self.x * self.x + self.y * self.y)
		end,
		
		normalize = function(self)
			local length = self:length()
			return vec2(self.x / length, self.y / length)
		end,
		
		reflect = function(self, normal)
			return normal * 2 * self:dot(normal) - self
		end,
		
		min = function(self, v)
			local min = vec2(self.x, self.y)
			if v.x < min.x then min.x = v.x end
			if v.y < min.y then min.y = v.y end
			return min
		end,
		
		max = function(self, v)
			local max = vec2(self.x, self.y)
			if v.x > max.x then max.x = v.x end
			if v.y > max.y then max.y = v.y end
			return max
		end
	}
}

function vec2(x, y)
	local v = {x = x, y = y}
	setmetatable(v, mt)
	return v
end
