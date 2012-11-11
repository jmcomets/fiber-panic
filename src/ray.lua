--[[ 
Fiber Panic
Copyright (c) 2012 Aurélien Defossez, Jean-Marie Comets, Anis Benyoub, Rémi Papillié
]]

require "src.config"
require "src.math.aabb"
require "src.segment"

Ray = {}
Ray.__index = Ray

function Ray.new(options)
	local self = {}
	setmetatable(self, Ray)

	-- Initialize attributes
	self.segments = {}
	self.actives = {}
    --self.waves = {}

	-- Create initial segment
	self:_createSegment {
		x = options.x,
		y = options.y,
		direction = options.direction,
		speed = options.speed
	}

	return self
end

-- Game logic update function
function Ray:update(dt)
	local toSplit = {}
	local widthSum = 0
	local raysCount = 0

	-- Update active segments
	for _, segment in pairs(self.actives) do
		if segment.dead then
			self:_stopSegment(segment)
		else
			segment:update(dt)
			widthSum = widthSum + segment.width
			raysCount = raysCount + 1
		end

		if math.random() < 0.01 then
			table.insert(toSplit, segment)
		end
	end

	if Config.randomSplits then
		for _, segment in pairs(toSplit) do
			local tip = segment:getTip()

			self:_stopSegment(segment)

			self:_createSegment {
				x = tip.x,
				y = tip.y,
				direction = vec2(segment.direction.x - 0.2, segment.direction.y - 0.2):normalize(),
				speed = segment.speed,
				with = math.ceil(segment.with / 2)
			}

			self:_createSegment {
				x = tip.x,
				y = tip.y,
				direction = vec2(segment.direction.x + 0.2, segment.direction.y + 0.2):normalize(),
				speed = segment.speed,
				with = math.ceil(segment.with / 2)
			}
		end
	end

	return {
		widthSum = widthSum,
		raysCount = raysCount
	}
end

-- Game graphics update function
function Ray:draw()
	-- Draw segments
	for _, segment in pairs(self.segments) do
		segment:draw()
	end
    --for _, wave in ipairs(self.waves) do 
        --love.graphics.arc("line", wave.x, wave.y, wave.radius, wave.angle1, wave.angle2)
    --end
end

-- Make the ray collide with the mirror, if collision there is
function Ray:checkMirrorCollision(mirror)
	local collisions = {}

	for _, segment in pairs(self.actives) do
		local collision = mirror:checkCollision {
			startPoint = segment.startPoint,
			endPoint = segment.tip
		}

		if collision.contact then
			local distanceVector = collision.point - segment.startPoint
			local distance = distanceVector:length()

			if distance > 5 then
				table.insert(collisions, {
					data = collision,
					segment = segment
				})
                --local angle = math.atan2(collision.normal.y, collision.normal.x)
                --table.insert(self.waves, {
                    --x = collision.point.x,
                    --y = collision.point.y,
                    --radius = 1,
                    --angle1 = angle + math.pi / 2,
                    --angle2 = angle - math.pi / 2
				--})
			end
		end
	end

	for _, collision in pairs(collisions) do	
	   local sound = love.audio.newSource(Config.sound.sfx.reflect, "static") 
	   love.audio.play(sound)
	   local segment = collision.segment
	   local data = collision.data

		-- Correct position of segment tip
		local overflow = (1 - data.factor) * segment.length
		segment:setLength(segment.length - overflow)

		-- Get new tip
 		local tip = segment:getTip()

		-- Stop segment
		self:_stopSegment(segment)

		-- Create new segment
		self:_createSegment {
			x = tip.x,
			y = tip.y,
			direction = data.reflection:normalize(),
			length = overflow,
			speed = segment.speed,
			width = segment.width
		}
	end

    --local delwaves = {}
    --for i, wave in ipairs(self.waves) do
        --wave.radius = wave.radius + 1
        --if wave.radius > 100 then
            --table.insert(delwaves, i)
        --end
    --end

    --for _, i in pairs(self.waves) do
        --table.remove(i)
    --end
end

function Ray:checkItemCollision(item)
	local collisions = {}

	for _, segment in pairs(self.actives) do
		table.insert(collisions, {
			ray = self,
			segment = segment,
			collision = item:checkCollision(segment)
		})
	end

	for _, collision in pairs(collisions) do
		item:resolveCollision(collision)
	end
end

-- Tests if the mirror collides with any of the segments
function Ray:testCollision(mirror)
	for _, segment in pairs(self.segments) do
		local collision = mirror:checkCollision{
			startPoint = segment.startPoint,
			endPoint = segment:getTip()
		}

		if collision.contact then
			return true
		end
	end

	return false
end

function Ray:computeBoundaries()
	local boundaries

	for _, segment in pairs(self.actives) do
		local tip = segment:getTip()

		if not boundaries then
			boundaries = aabb(tip, tip)
		else
			boundaries:expand(tip)
		end
	end

	return boundaries
end

function Ray:_createSegment(options)
	local segment = Segment.new(options)

	table.insert(self.segments, segment)
	self.actives[segment.id] = segment

	return segment
end

function Ray:_stopSegment(segment)
	segment:stop()
	self.actives[segment.id] = nil
end

function Ray:_getFirstActiveSegment()
	for _, segment in pairs(self.actives) do
		return segment
	end
end
