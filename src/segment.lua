--[[ 
Fiber Panic
Copyright (c) 2012 Aurélien Defossez, Jean-Marie Comets, Anis Benyoub, Rémi Papillié
]]

require "src.config"
require "src.math.vec2"

Segment = {}
Segment.__index = Segment

idCounter = 1

function Segment.new(options)
	local self = {}
	setmetatable(self, Segment)

	-- Initialize attributes
	self.id = idCounter
	self.startPoint = vec2(options.x, options.y)
	self.direction = vec2(options.direction.x, options.direction.y)
	self.width = options.width or Config.rayStartWidth
	self.startWidth = self.width
	self.speed = options.speed or Config.rayStartSpeed
	self.length = options.length or 0
	self.active = true
	self.tip = self:computeTip()
	self.dead = false

	idCounter = idCounter + 1

	return self
end

-- Game logic update function
function Segment:update(dt)
	if self.active and not self.dead then
		self.length = self.length + dt * self.speed
		self.speed = self.speed + dt * Config.rayAcceleration
		self.width = self.width - dt * .5
		self.previousTip = self.tip
	end

	self.tip = self:computeTip()
end

-- Game graphics update function
function Segment:draw()
	local endPoint = self:getTip()
	local perp = self.direction:perp()
	local startPerp = perp * self.startWidth / 2
	local endPerp = perp * self.width / 2
	local points = {
		self.startPoint - startPerp,
		self.startPoint + startPerp,
		endPoint + endPerp,
		endPoint - endPerp
	}

	local vertices = {}
	for _, point in pairs(points) do
		table.insert(vertices, point.x)
		table.insert(vertices, point.y)
	end

	local lineColor = Config.rayColor
	love.graphics.setColor(lineColor.r, lineColor.g, lineColor.b, lineColor.a)
	love.graphics.polygon('fill', vertices)
	
	local highlightStart = self.startPoint - startPerp * 0.4
	local highlightEnd = endPoint - endPerp * 0.4
	love.graphics.setColor(255, 255, 255, 100)
	love.graphics.setLineWidth(2)
	love.graphics.line(highlightStart.x, highlightStart.y, highlightEnd.x, highlightEnd.y)
end

function Segment:computeTip()
	return self.startPoint + self.direction * self.length
end

function Segment:getTip()
	return self.tip
end

function Segment:setLength(length)
	self.length = length
	self.tip = self:computeTip();
end

function Segment:setWidth(width)
	self.width = math.max(0, math.min(width, Config.rayMaxWidth))

	if self.width == 0 then
		self.dead = true
	end
end

function Segment:stop()
	self.active = false
end
