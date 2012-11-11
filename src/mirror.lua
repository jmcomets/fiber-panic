--[[ 
Fiber Panic
Copyright (c) 2012 Aurélien Defossez, Jean-Marie Comets, Anis Benyoub, Rémi Papillié
]]

require "src.config"
require "src.math.vec2"

Mirror = {}
Mirror.__index = Mirror

-- Configuration for Mirror
Mirror.topImage = love.graphics.newImage(Config.images.mirror.top)
Mirror.middleImage = love.graphics.newImage(Config.images.mirror.middle)
Mirror.bottomImage = love.graphics.newImage(Config.images.mirror.bottom)

-- Mirror's constructor.
--
-- Options:
--  * start and end points defined by (x1, y1) and (x2, y2)
function Mirror.new(options)
	local self = {}
	setmetatable(self, Mirror)

    self.origin = options.origin
    self.extent = options.extent
	
	return self
end

-- Game logic update function
function Mirror:update(dt)
end

-- Game graphics update function
function Mirror:draw()
    local angle = math.atan2(self.extent.y, self.extent.x) + math.pi * 0.5
    local yscale = 1
    local len_extend = self.extent:length()
    if len_extend > 0 then
        yscale = len_extend / Mirror.middleImage:getHeight()
    end
	
    love.graphics.draw(Mirror.topImage, self.origin.x + self.extent.x, self.origin.y + self.extent.y, angle, 1, 1, Mirror.topImage:getWidth() * 0.5, 0)
    love.graphics.draw(Mirror.bottomImage, self.origin.x - self.extent.x, self.origin.y - self.extent.y, angle, 1, 1, Mirror.bottomImage:getWidth() * 0.5, Mirror.bottomImage:getHeight())

	local extentLength = self.extent:length()
	local middleLength = extentLength - 32
    love.graphics.draw(Mirror.middleImage, self.origin.x, self.origin.y, angle, 1, middleLength, Mirror.topImage:getWidth() * 0.5, 0)
    love.graphics.draw(Mirror.middleImage, self.origin.x, self.origin.y, angle, 1, -middleLength, Mirror.topImage:getWidth() * 0.5, 0)
end

-- Check collision with a given line.
--
-- Parameters:
--  * start and end points defined by vec2 objects
--
-- Returns:
--  * contact -> if there is intersection (boolean)
--  * point -> intersection point (vec2)
--  * factor -> coefficient between the start point of
--      the arriving segment and the intersection point
function Mirror:checkCollision(options)
    -- Return variable
    local collision = {
        contact = true,
        point = nil,
        normal = nil,
        factor = nil
    }
	
    -- Variable definitions
    local p1 = options.startPoint
    local p2 = options.endPoint
    local q1 = self.origin - self.extent
    local q2 = self.origin + self.extent
    local a = q2 - q1
    local b = p2 - p1
    local c = p1 - q1
    local d = c:dot(a:perp())
    local e = c:dot(b:perp())
    local f = a:dot(b:perp())
    collision.a = d
    collision.b = e
    collision.c = f

    -- Algorithm
    if f > 0 then
        if d < 0 or d > f then
            collision.contact = false
        end
    elseif d > 0 or d < f then
        collision.contact = false
    end

    local s = d / f
    local t = e / f
    if t < 0 or t > 1 then
        collision.contact = false
    end

	-- Compute normal
	collision.normal = self.extent:perp():normalize()
	if collision.normal:dot(c) < 0 then
		collision.normal = -collision.normal
	end
	
	-- Reflect input vector
	collision.reflection = -b:reflect(collision.normal)
	
    -- Return the collision point
    if collision.contact then
        collision.factor = s
        collision.point = p1 + (p2 - p1) * s
    end

    return collision
end
