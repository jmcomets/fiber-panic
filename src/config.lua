--[[
Fiber Panic
Copyright (c) 2012 Aurélien Defossez, Jean-Marie Comets, Anis Benyoub, Rémi Papillié
]]

Config = {
	-- Camera config
	virtualScreenHeight = 1080,
	
	-- Game config
	rayStartWidth = 23,
	rayMaxWidth = 40,
	rayStartSpeed = 200,
	rayAcceleration = 20,
	sourceItemWidthGrowth = math.sqrt(42) / 10,
	prismItemDelta = 0.02,
    prismAmount = 10,
    sourceAmount = 10,

	-- Camera
	camera = {
		-- defined around 1080px
		minVirtualHeight = 1080,
		maxVirtualHeight = 4000,
		
		-- minimum space around rays (won't go off the previous max)
		rayPadding = 1080
	},
	
	-- Colors
	rayColor = {
		r = 230,
		g = 220,
		b = 100,
		a = 210
	},

    -- Obstacle constants
    obstacles = {
        damages = {
            smoke1 = 0.15,
            water1 = 0.25,
            water2 = 0.25,
            slime1 = 0.35
        },
        speeds = {
        	smoke1 = 0.9,
            water1 = 0.7,
            water2 = 0.7,
            slime1 = 0.5
	    },
        defaultWidth = 100,
        defaultHeight = 100
    },
	
    -- Image urls
    imageDirectory = "assets",
	
	-- Debug parameters
	slowMode = false,
	fastMode = false,
	oneRay = true,
	randomSplits = false
}

Config.images = {
    background = Config.imageDirectory .. "/background2.png",
	items = {
        generator = Config.imageDirectory .. "/Generator.png",
        wayout = Config.imageDirectory .. "/Wayout.png",

        source = Config.imageDirectory .. "/ItemSource.png",
        prism = Config.imageDirectory .. "/Prism.png",
	},
    obstacles = {
        water1 = Config.imageDirectory .. "/water1.png",
        water2 = Config.imageDirectory .. "/water2.png",
        slime1 = Config.imageDirectory .. "/slime1.png",
        smoke1 = Config.imageDirectory .. "/smoke1.png",
        walls1 = Config.imageDirectory .. "/walls1.jpg"
    },
    mirror = {
        top = Config.imageDirectory .. "/MirrorTop.png",
        middle = Config.imageDirectory .. "/MirrorMiddle.png",
        bottom = Config.imageDirectory .. "/MirrorBottom.png"
    }
}

Config.sound = {
   generaltheme = Config.imageDirectory .. "/bs-dropzone.mp3",
   sfx =  {
        die = Config.imageDirectory .. "/die.wav",
        reflect = Config.imageDirectory .. "/reflect.wav",
        smaller = Config.imageDirectory .. "/smaller.wav",
        split = Config.imageDirectory .. "/split.wav",
        bigger = Config.imageDirectory .. "/bigger.wav"

   }

}
