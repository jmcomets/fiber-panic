--[[ 
Fiber Panic
Copyright (c) 2012 Aurélien Defossez, Jean-Marie Comets, Anis Benyoub, Rémi Papillié
]]

require "src.config"
require "src.source"
require "src.prism"
require "src.obstacle"
require "src.exit"

Map = {}
Map.__index = Map

Map.background = love.graphics.newImage(Config.images.background)

function Map.new(options)
    local self = {}
    setmetatable(self, Map)

    self:reset()
    self:generate()

    return self
end

function Map:reset()
    self.items = {}
end

function Map:generate()

    local cellSize = 270
    local corridorLength = 5
    local spawnSafeZone = 500
    local spaceSize = { rows = 42, cols = 42 }
    local proportions = {
        smoke1 = 2,
        water1 = 1,
        water2 = 1,
        slime1 = 1,
        source = 2,
        prism  = 1
    }

    self:_makeWalls(corridorLength)

    print("Creating corridor...")

    -- self:placeItems{
    --     rows = 3,
    --     cols = corridorLength,
    --     nbItems = corridorLength,
    --     xoffset = spawnSafeZone,
    --     yoffset = -550,
    --     cellSize = cellSize,
    --     proportions = proportions,
    --     placeExit = false
    -- }

    print("Creating space...")

    self:placeItems{
        rows = spaceSize.rows,
        cols = spaceSize.cols,
        nbItems = spaceSize.rows * spaceSize.cols / 3,
        xoffset = corridorLength * cellSize + spawnSafeZone,
        yoffset = -spaceSize.rows / 2 * cellSize,
        cellSize = cellSize,
        proportions = proportions,
        placeExit = true
    }

    print("Environment generated")
end

function Map:placeItems(options)
    local grid = {}
    local itemCt = 0

    if options.placeExit then
        local row = math.random(1, options.rows)
        local col = math.random(1, options.cols)

        local position = vec2(options.xoffset + col * options.cellSize, options.yoffset + row * options.cellSize)

        grid[row] = {}
        grid[row][col] = self:_makeExit(position)
    end

    repeat
        for type, proportion in pairs(options.proportions) do
            for i = 0, proportion do
                local placed = false

                repeat
                    local row = math.random(1, options.rows)
                    local col = math.random(1, options.cols)

                    if not grid[row] then
                        grid[row] = {}
                    end

                    if not grid[row][col] and (col % 2 == 0 or row <= 2) then
                        local position = vec2(options.xoffset + col * options.cellSize,
                            options.yoffset + row * options.cellSize)
                        local item

                        if type == "smoke1" or type == "water1" or type == "water2" or type == "slime1" then
                            item = self:_makeObstacle{
                                type = type,
                                position = position
                            }
                        elseif type == "source" then
                            item = self:_makeSource(position)
                        elseif type == "prism" then
                            item = self:_makePrism(position)
                        end

                        grid[row][col] = item
                        itemCt = itemCt + 1
                        placed = true
                    end
                until placed
            end
        end
    until itemCt >= options.nbItems
end

-- Game logic update: update items
function Map:update(dt)
    for _, item in ipairs(self.items) do
        item:update(dt)
    end
end

-- Game rendering: draw background / items
function Map:draw(aabb)
    -- Draw background
	local startX = math.floor(aabb.min.x / Map.background:getWidth())
	local endX = math.floor(aabb.max.x / Map.background:getWidth())
	local startY = math.floor(aabb.min.y / Map.background:getHeight())
	local endY = math.floor(aabb.max.y / Map.background:getHeight())
    for y = startY, endY do
		for x = startX, endX do
            love.graphics.draw(self.background, x * Map.background:getWidth(), y * Map.background:getHeight())
        end
    end

    -- Draw items
    for _, item in ipairs(self.items) do
        item:draw()
    end
end

-- Check collision with items
function Map:checkRayCollisions(ray)
    for _, item in ipairs(self.items) do
        ray:checkItemCollision(item)
    end
end

-- Generate walls
function Map:_makeWalls(rows)
    local img = love.graphics.newImage(Config.images.obstacles["walls1"])

    -- Left walls
    table.insert(self.items, Obstacle.new({
        center = vec2(-140, img:getWidth() - 200),
        type = "walls1",
        instantkill = true,
        angle = math.pi / 2,
    }))
    table.insert(self.items, Obstacle.new({
        center = vec2(-140, img:getWidth() - 600),
        type = "walls1",
        instantkill = true,
        angle = math.pi / 2,
    }))

    for i = 0, rows do
        -- Top walls
        table.insert(self.items, Obstacle.new({
            center = vec2(i * img:getWidth(), -500),
            type = "walls1",
            -- instantkill = true,
            reflect = true
        }))

        -- Bottom walls
        table.insert(self.items, Obstacle.new({
            center = vec2(i * img:getWidth(), 500),
            type = "walls1",
            -- instantkill = true,
            reflect = true,
            angle = math.pi
        }))
    end
end

-- Generate sources
function Map:_makeSource(options)
    local item = Source.new(options)
    table.insert(self.items, item)
    return item
end

-- Generate prisms
function Map:_makePrism(options)
    local item = Prism.new(options)
    table.insert(self.items, item)
    return item
end

-- Generate exit
function Map:_makeExit(options)
    local item = Exit.new(options)
    table.insert(self.items, item)
    return item
end

-- Generate other obstacles
function Map:_makeObstacle(options)
    local img = love.graphics.newImage(Config.images.obstacles[options.type])
    local item = Obstacle.new{
        center = options.position,
        type = options.type,
        angle = options.angle or math.random(-math.pi, math.pi)
    }

    table.insert(self.items, item)

    return item
end
