--[[ 
Fiber Panic
Copyright (c) 2012 Aurélien Defossez, Jean-Marie Comets, Anis Benyoub, Rémi Papillié
]]

require "src.game"

function love.load()
	game = Game.new({})
end

function love.mousepressed(x, y, button)
	game:mousePressed(x, y, button)
end

function love.mousereleased(x, y, button)
	game:mouseReleased(x, y, button)
end

function love.keypressed(key, unicode)
	if key == "escape" then
		love.event.push("quit")
    elseif key == "r" then
        game:reset()
    elseif key == " " then
        game:togglePause()
	end
end

function love.update(dt)
	if dt > 0.1 then
		dt = 0.1
	end
	game:update(dt)
end

function love.draw()
	game:draw()
end
