--[[ 
Fiber Panic
Copyright (c) 2012 Aurélien Defossez, Jean-Marie Comets, Anis Benyoub, Rémi Papillié
]]

require "src.config"
require "src.math.vec2"
require "src.math.obb"

Obstacle = {}
Obstacle.__index = Obstacle

-- Obstacle's constructor.
--
-- Call example:
--    obstacle = Obstacle.new({
--       type = "water",
--       angle = math.pi / 3,
--       scale = 1,5,
--       instantkill = true,
--       center = {
--         x = 2,
--         y = 5,
--       }
--    })
function Obstacle.new(options)
	local self = {}
	setmetatable(self, Obstacle)
	
	self.angle = options.angle or 0
	self.scale = options.scale or 1

	self.image = love.graphics.newImage(Config.images.obstacles[options.type])
	self.damage = Config.obstacles.damages[options.type] or 0
	self.speed = Config.obstacles.speeds[options.type] or 0
	self.instantkill = options.instantkill or false
	self.reflect = options.reflect or false
	self.segments = {}

	local localX = vec2(math.cos(self.angle) * self.image:getWidth() * self.scale, math.sin(self.angle) * self.image:getWidth() * self.scale)
	local localY = vec2(math.cos(self.angle + math.pi * 0.5) * self.image:getHeight() * self.scale, math.sin(self.angle + math.pi * 0.5) * self.image:getHeight() * self.scale)
	self.box = obb(options.center, localX * 0.5, localY * 0.5)

	return self
end

-- Game logic update function
function Obstacle:update(dt)
end

-- Game graphics update function
function Obstacle:draw()
	love.graphics.draw(self.image, self.box.center.x, self.box.center.y, self.angle,
		self.scale, self.scale,
		self.image:getWidth() * 0.5, self.image:getHeight() * 0.5)

	--self.box:drawDebug()
end

-- Collision check with points: delegate to Box
function Obstacle:checkCollision(segment)
	return self.box:contains(segment.tip)
end

function Obstacle:resolveCollision(event)
	local ray = event.ray
	local segment = event.segment
	local tip = segment:getTip()

	if event.collision then
		if self.instantkill then
			local sound = love.audio.newSource(Config.sound.sfx.die, "static") 
			love.audio.play(sound)
			ray:_stopSegment(segment)
		elseif self.reflect and segment.length > 5 then
		   local sound = love.audio.newSource(Config.sound.sfx.reflect, "static") 
		   love.audio.play(sound)

			-- Correct position of segment tip
			local overflow = math.abs(segment.tip.y) - (500 - 117)
			-- local overflow = (1 - data.factor) * segment.length
			segment:setLength(segment.length - overflow)

			-- Get new tip
	 		local tip = segment:getTip()

			-- Stop segment
			ray:_stopSegment(segment)

			-- Create new segment
			ray:_createSegment {
				x = tip.x,
				y = tip.y,
				direction = segment.direction * vec2(1, -1),
				length = overflow,
				speed = segment.speed,
				width = segment.width
			}
		else
			if not self.segments[segment.id] then
				local sound = love.audio.newSource(Config.sound.sfx.smaller, "static") 
				love.audio.play(sound)

				-- Collision detected and segment not yet handled: Create new growing segment
				ray:_stopSegment(segment)

				local newSegment = ray:_createSegment {
					x = tip.x,
					y = tip.y,
					direction = segment.direction,
					speed = segment.speed * self.speed,
					width = segment.width
				}

				self.segments[newSegment.id] = newSegment
			else
				-- Collision detected for handled segment: Add width
				segment:setWidth(segment.width - self.damage / (Config.rayStartSpeed / segment.speed))
			end
		end
	elseif self.segments[segment.id] then
		-- End of collision detected, stopping growth
		ray:_stopSegment(segment)
		self.segments[segment.id] = nil

		local newSegment = ray:_createSegment {
			x = tip.x,
			y = tip.y,
			direction = segment.direction,
			speed = segment.speed / self.speed,
			width = segment.width
		}
	end
end
