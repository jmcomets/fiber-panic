--[[ 
The NoName Fiber Game
Copyright (c) 2012 Aurélien Defossez, Jean-Marie Comets, Anis Benyoub, Rémi Papillié
]]

require "src.config"
require "src.math.collisions"

Source = {}
Source.__index = Source

Source.background = love.graphics.newImage(Config.images.items.source)

function Source.new(options)
	local self = {}
	setmetatable(self, Source)

	-- Initialize attributes
	self.x = options.x
	self.y = options.y
	self.radius = 80
	self.segments = {}

	return self
end

-- Game logic update function
function Source:update(dt)
end

-- Game graphics update function
function Source:draw()
	love.graphics.setColor(20, 230, 20)

	--love.graphics.circle('fill', self.x, self.y, self.radius, 16)
	love.graphics.draw(Source.background, self.x, self.y, love.timer.getTime(), 1, 1, Source.background:getWidth() * 0.5, Source.background:getHeight() * 0.5)
	--love.graphics.draw(Source.background, self.x, self.y, -love.timer.getTime() * 1.7, 1, 1, Source.background:getWidth() * 0.5, Source.background:getHeight() * 0.5)
end

function Source:checkCollision(segment)
	local tip = segment:getTip()
	return collisions.pointInCircle(tip.x, tip.y, self.x, self.y, self.radius)
end

function Source:resolveCollision(event)
	local ray = event.ray
	local segment = event.segment
	local tip = segment:getTip()

	if event.collision then
		if not self.segments[segment.id] then
			-- Collision detected and segment not yet handled: Create new growing segment
			local sound = love.audio.newSource(Config.sound.sfx.bigger, "static") 
			love.audio.play(sound)
			
			ray:_stopSegment(segment)

			local newSegment = ray:_createSegment {
				x = tip.x,
				y = tip.y,
				direction = segment.direction,
				speed = segment.speed,
				width = segment.width
			}

			self.segments[newSegment.id] = newSegment
		else
			-- Collision detected for handled segment: Add width
			segment:setWidth(segment.width +
				Config.sourceItemWidthGrowth / (Config.rayStartSpeed / segment.speed))
			end
	elseif self.segments[segment.id] then
		-- End of collision detected, stopping growth
		ray:_stopSegment(segment)
		self.segments[segment.id] = nil

		local newSegment = ray:_createSegment {
			x = tip.x,
			y = tip.y,
			direction = segment.direction,
			speed = segment.speed,
			width = segment.width
		}
	end
end
