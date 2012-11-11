local mt = {
	__index = {
        contains = function(self, vector)
            local relativeVector = vector - self.center
			local projectedX = relativeVector:dot(self.extentX) / (self.halfWidth * self.halfWidth)
			local projectedY = relativeVector:dot(self.extentY) / (self.halfHeight * self.halfHeight)
			return math.abs(projectedX) <= 1 and math.abs(projectedY) <= 1
        end,
		
		getWidth = function(self)
			return self.halfWidth * 2
		end,
		
		getHeight = function(self)
			return self.halfHeight * 2
		end,

		drawDebug = function(self)
	    	local points = {
				self.center - self.extentX - self.extentY,
				self.center - self.extentX + self.extentY,
				self.center + self.extentX + self.extentY,
				self.center + self.extentX - self.extentY
			}

			local vertices = {}
			for _, point in pairs(points) do
				table.insert(vertices, point.x)
				table.insert(vertices, point.y)
			end

			local lineColor = gameConfig.rayColor
			love.graphics.setColor(255, 0, 0, 255)
			love.graphics.polygon('line', vertices)
		end
	}
}

function obb(center, extentX, extentY)
	local box = {
        center = center,
        extentX = extentX,
        extentY = extentY,
		halfWidth = extentX:length(),
		halfHeight = extentY:length()
    }
    setmetatable(box, mt)

	return box
end
