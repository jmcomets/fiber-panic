--[[ 
Fiber Panic
Copyright (c) 2012 Aurélien Defossez, Jean-Marie Comets, Anis Benyoub, Rémi Papillié
]]

require "src.config"
require "src.math.vec2"
require "src.math.collisions"

Prism = {}
Prism.__index = Prism

Prism.image = love.graphics.newImage(Config.images.items.prism)

function Prism.new(options)
	local self = {}
	setmetatable(self, Prism)

	-- Initialize attributes
	self.pos = vec2(options.x, options.y)
	self.height = 100

	return self
end

-- Game logic update function
function Prism:update(dt)
end

-- Game graphics update function
function Prism:draw()
	local longHeight = 2 * self.height / 3
	local shortHeight = self.height / 3
	
	love.graphics.draw(Prism.image, self.pos.x, self.pos.y, love.timer.getTime(), 1, 1, Prism.image:getWidth() * 0.5, Prism.image:getHeight() * 0.5)
end

function Prism:checkCollision(segment)
	if segment.previousTip and (self.pos - segment.tip):length() < self.height / 2 then
		local previousBeta = self:_computeAngle(segment.startPoint, segment.previousTip)
		local beta = self:_computeAngle(segment.startPoint, segment.tip)
		local tip = segment:getTip()

		return previousBeta > 90 and beta <= 90
	else
		return false
	end
end

function Prism:_computeAngle(startPoint, tip)
	local a = (self.pos - tip):length()
	local b = (startPoint - self.pos):length()
	local c = (startPoint - tip):length()
	return math.acos((a * a + c * c - b * b) / (2 * a * c)) * 180 / math.pi
end

function Prism:resolveCollision(event)
	local ray = event.ray
	local segment = event.segment
	local tip = segment:getTip()

	if event.collision then
		local sound = love.audio.newSource(Config.sound.sfx.split, "static") 
		love.audio.play(sound)

		ray:_stopSegment(segment)

		local width = math.ceil(segment.width * 3 / 4)
		local pos1 = tip + segment.direction:perp() * (width / 4)
		local pos2 = tip + segment.direction:perp() * (-width / 4)

		local newSegment1 = ray:_createSegment {
		x = pos1.x,
		y = pos1.y,
		direction = (segment.direction + segment.direction:perp() * Config.prismItemDelta):normalize(),
		speed = segment.speed,
		width = width
	}

	local newSegment2 = ray:_createSegment {
	x = pos2.x,
	y = pos2.y,
	direction = (segment.direction - segment.direction:perp() * Config.prismItemDelta):normalize(),
	speed = segment.speed,
	width = width
}
end
end
