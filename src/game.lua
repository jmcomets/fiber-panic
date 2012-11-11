--[[ 
Fiber Panic
Copyright (c) 2012 Aurélien Defossez, Jean-Marie Comets, Anis Benyoub, Rémi Papillié
]]

require("src.config")
require("src.map")
require("src.mirror")
require("src.ray")
require("src.math.aabb")
require("src.math.vec2")

Game = {}
Game.__index = Game

function Game.new(options)
    local self = {}
    setmetatable(self, Game)
	
    -- the game has a virtual height
	self.virtualScreenHeight = Config.camera.minVirtualHeight
    self.virtualScaleFactor = love.graphics.getHeight() / self.virtualScreenHeight
    self.screenRatio = love.graphics.getWidth() / love.graphics.getHeight()
    
	love.graphics.setFont(love.graphics.newFont(40))
	
    music = love.audio.newSource(Config.sound.generaltheme)
    love.audio.play(music)

    self:reset()

    return self
end

function Game:reset()
    -- Initialize attributes
    self.rays = {}
    self.mirrors = {}
    self.map = Map.new()
    self.running = true
    self.dead = false
    self.win = false
    self.score = 0
	
    -- mirror drawing
    self.mouseStart = vec2(0, 0)
    self.currentMirror = nil
	
    -- Create rays
    self:_createRay{
        x = 0,
        y = 0,
        direction = vec2(1, 0)
    }
	
    if not Config.oneRay then
        self:_createRay{
            x = 0,
            y = Config.rayStartWidth * 3,
            direction = vec2(1, 0)
        }
		
        self:_createRay{
            x = 0,
            y = Config.rayStartWidth * 6,
            direction = vec2(1, 0)
        }
    end
	
    self.camera = vec2(0, 0)
	self.zoom = 1.0
	
    -- configure texture blending with current color
    love.graphics.setColorMode("replace")
	
    -- loading the generator
    self.generator = love.graphics.newImage(Config.images.items.generator)
	
    -- loading the wayout
    self.wayout = love.graphics.newImage(Config.images.items.wayout)
end

function Game:mousePressed(x, y, button)
    self.mouseStart = vec2(x, y)
	
    local worldSpaceStart = self:_screenToWorld(self.mouseStart)
    self.currentMirror = Mirror.new({origin = worldSpaceStart, extent = vec2(0, 0)})
end

function Game:mouseReleased(x, y, button)
    local mirror = self.currentMirror
    self.currentMirror = nil
    if self.running == true then
        -- Check if the mirror can be placed (i.e. not blocking an existing ray)
        for _, ray in ipairs(self.rays) do
            -- check collision with the new mirrors
            if ray:testCollision(mirror) then
                return
            end
        end

        table.insert(self.mirrors, mirror)
    end
end

function Game:update(dt)
    if Config.slowMode then
        dt = dt / 4
    elseif Config.fastMode then
        dt = dt * 4
    end

    if self.running == true then 
        -- update mirrors
        if self.currentMirror then self.currentMirror:update(dt) end
        for _, mirror in ipairs(self.mirrors) do
            mirror:update(dt)
        end

        local widthSum = 0
        local raysCount = 0
        
        -- update rays
        for _, ray in ipairs(self.rays) do
            local stats = ray:update(dt)
            widthSum = widthSum + stats.widthSum
            raysCount = raysCount + stats.raysCount

            -- check collision with mirrors
            for _, mirror in ipairs(self.mirrors) do
                ray:checkMirrorCollision(mirror)
            end
            
            -- check collision with items
            self.map:checkRayCollisions(ray)
        end

        -- Update score
        self.score = self.score + math.ceil(widthSum * math.log(raysCount + 1) / 42 * dt)
        
        -- update map
        self.map:update(dt)
		
        -- mirror being drawn
        if love.mouse.isDown("l") then
            local start = self:_screenToWorld(self.mouseStart)
            local mouse = self:_screenToWorld(vec2(love.mouse.getX(), love.mouse.getY()))
            self.currentMirror.origin = start
            self.currentMirror.extent = mouse - start
            --love.graphics.line(start.x, start.y, mouse.x, mouse.y)
        end
        
        -- align camera with ray end
        local newBounds = nil
        for i, ray in ipairs(self.rays) do
            local bounds = ray:computeBoundaries()
            if bounds then
                if not newBounds then
                    newBounds = bounds
                else
                    newBounds:merge(bounds)
                end
            end
        end
		if not newBounds then self.dead = true end
        self.tipBounds = newBounds or self.tipBounds or aabb(vec2(0, 0), vec2(0, 0))
        self.camera = (self.tipBounds.min + self.tipBounds.max) * 0.5
        self.virtualScreenHeight = self.tipBounds.max.y - self.tipBounds.min.y + Config.camera.rayPadding
		local virtualScreenWidth = self.tipBounds.max.x - self.tipBounds.min.x + Config.camera.rayPadding
		if (virtualScreenWidth / self.screenRatio) > self.virtualScreenHeight then self.virtualScreenHeight = (virtualScreenWidth / self.screenRatio) end
        if self.virtualScreenHeight < Config.camera.minVirtualHeight then self.virtualScreenHeight = Config.camera.minVirtualHeight end
        --if self.virtualScreenHeight > Config.camera.maxVirtualHeight then self.virtualScreenHeight = Config.camera.maxVirtualHeight end
        self.virtualScaleFactor = love.graphics.getHeight() / self.virtualScreenHeight
        --self.camera = self.rays[1]:getActiveTip()
		
		if self.win or self.dead then
			self.running = false
		end
    end
end

function Game:draw()
	love.graphics.push()
	
    -- apply virtual resolution before rendering anything
    love.graphics.scale(self.virtualScaleFactor, self.virtualScaleFactor)
	
	-- apply camera zoom
	love.graphics.scale(self.zoom, self.zoom)
	
    -- move to camera position
    love.graphics.translate((self.virtualScreenHeight * 0.5 / self.zoom) * self.screenRatio - self.camera.x, (self.virtualScreenHeight * 0.5 / self.zoom) - self.camera.y)
	
    -- draw background
	local screenExtent = vec2(self.virtualScreenHeight * self.screenRatio, self.virtualScreenHeight)
	local cameraBounds = aabb(self.camera - screenExtent, self.camera + screenExtent)
    self.map:draw(cameraBounds)
	
    --love.graphics.print("0, 0", 0, 0)
    --love.graphics.print("0, -50", 0, -50)
    --love.graphics.print("0, 50", 0, 50)
    --love.graphics.print("-50, 0", -50, 0)
    --love.graphics.print("50, 0", 50, 0)
	
    -- draw the light generator
    love.graphics.draw(self.generator,-100,-60,0,0.26,0.26)

    -- draw rays
    love.graphics.setColor(230, 220, 100, 210)
    for _, ray in ipairs(self.rays) do
        ray:draw()
    end

    -- draw mirrors
    for _, mirror in ipairs(self.mirrors) do
        mirror:draw()
    end
    if self.currentMirror then self.currentMirror:draw() end
	
	-- reset camera transform before hud drawing
	love.graphics.pop()
	
    if self.running == false then
        love.graphics.setColor(0, 0, 0, 200)
        love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
        love.graphics.setColor(255, 255, 220, 255)
        love.graphics.print("R: RETRY", love.graphics.getWidth() / 2 - 300, love.graphics.getHeight() / 2 - 100)
        love.graphics.print("SPACE: PAUSE / UNPAUSE", love.graphics.getWidth() / 2 - 300, love.graphics.getHeight() / 2 + 100)
		love.graphics.setColor(255, 0, 210, 200)
		love.graphics.print("SCORE: " .. self.score, love.graphics.getWidth() - 300, 50)
        if self.dead == true then
            love.graphics.print("YOU LOST", 50, 50)
        end
        if self.win == true then
            love.graphics.print("YOU WON", 50, 50)
        end
	else
		-- ingame hud
		love.graphics.setColor(255, 0, 210, 200)
		love.graphics.print(self.score, love.graphics.getWidth() - 300, 50)
    end

end

function Game:_screenToWorld(vector)
    local screenSpaceCamera = vec2(love.graphics.getWidth() * 0.5, love.graphics.getHeight() * 0.5)
    local relativePosition = (vector - screenSpaceCamera) / vec2(self.virtualScaleFactor * self.zoom, self.virtualScaleFactor * self.zoom)
    return relativePosition + self.camera
end

function Game:_createRay(options)
    table.insert(self.rays, Ray.new(options))
end

function Game:togglePause()
    self.running = (self.running == false and self.dead == false)
end
