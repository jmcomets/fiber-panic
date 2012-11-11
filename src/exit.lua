--[[ 
Fiber Panic
Copyright (c) 2012 Aurélien Defossez, Jean-Marie Comets, Anis Benyoub, Rémi Papillié
]]

require "src.config"
require "src.math.collisions"

Exit = {}
Exit.__index = Exit

function Exit.new(options)
	local self = {}
	setmetatable(self, Exit)

	-- Initialize attributes
	self.x = options.x
	self.y = options.y
	self.radius = 142

	return self
end

-- Game logic update function
function Exit:update(dt)
end

-- Game graphics update function
function Exit:draw()
	love.graphics.setColor(20, 20, 20)
	love.graphics.circle('fill', self.x, self.y, self.radius, 32)
end

function Exit:checkCollision(segment)
	local tip = segment:getTip()
	return collisions.pointInCircle(tip.x, tip.y, self.x, self.y, self.radius)
end

function Exit:resolveCollision(event)
	if event.collision then
		game.win = true
		game.score = game.score + 1000
	end
end
