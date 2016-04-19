---------------------------------------------------------------------------
--HOW TO:
-- 1. Add your game mode
-- 2. Add your init function
-- 3. Add your loop function

--Use the function galconStop(winner) to stop the game. 
--Pass the user who won as an argument. If nobody won pass a nil value.

--Dont use the global namespace for your variables or functions.
--Use OPTS.mode["YourModeNameHere"] 
---------------------------------------------------------------------------


function init_zap()
---------------------------------------------------------------------------
--ADD THE MODE
---------------------------------------------------------------------------
local mode = {}
GAME.mode:addMode(mode,"zap")
mode.description = "Hey, I thi....ZAP! "
mode.presets = {}
	
	

mode:addPreset("default","Nothing special.",
{
	
})




---------------------------------------------------------------------------
--SETTINGS
---------------------------------------------------------------------------
--ADD SETTINGS (if you have no settings the user can set, just do settings = {})
--Players can set the settings with commands.
-- Settings are displayed in the lobby.
--For example here players will be able to type:
-- "/neutrals 30 50" to set neutrals to {30,40}
-- or "/startprod 150" to set startprod to {150}
-- "/neutrals 30" will set neutrals to {30,30}
-- Please do not use conflicting names
-- Input values will always be numbers and cant be nil
mode.settings = shallowCopy(mode.presets[mode.currentPreset].settings)

---------------------------------------------------------------------------
--LIMIT SETTINGS VALUES
---------------------------------------------------------------------------
-- If you want to limit the settings numbers so input values cant go overboard do it here.
-- Note: If you are using math.random(var1,var2) then var2 >= var1 or it will
-- throw an error! If var1 > var2 you could just set var2 = var1
mode.limitValues = function()
end


---------------------------------------------------------------------------
--INIT FUNCTION, called when a game is started with /start
--Needs to be named and have the exact same signature as here
---------------------------------------------------------------------------
mode.init = function(users,neutral)

--save any data needed for this mode
local data = {}
data.winTime = 5
data.winT = data.winTime
data.users = users
data.killTimer = 0

mode.data = data



local settings = mode.settings



--[[
if(#users == 2) then
-- make a symmetric map
local numPlanets = math.random(settings["neutrals"][1],settings["neutrals"][2])
   for i=1,numPlanets/2 do
        local x = sw/2 + math.random(-(sw)/2,(sw)/2)
        local y = sh/2 + math.random(-(sh)/2,(sh)/2)
        local prod = math.random(settings["neutprod"][1],settings["neutprod"][2])
        local cost = math.random(settings["neutcost"][1],settings["neutcost"][2])
        g2.new_planet(neutral, x, y, prod, cost);
        g2.new_planet(neutral, sw - x, sh - y, prod, cost);
   end
else
local numPlanets = math.random(settings["neutrals"][1],settings["neutrals"][2])
   for i=1,numPlanets do
        local x = math.random(0,sw)
        local y = math.random(0,sh)
        local prod = math.random(settings["neutprod"][1],settings["neutprod"][2])
        local cost = math.random(settings["neutcost"][1],settings["neutcost"][2])
        g2.new_planet(neutral, x, y, prod, cost);
   end
end
--]]
  local sw = 800
   local sh = 500
   local numPlanets = 50
   local numUsers = #users
  -- numUsers = 12
   sw = 650+numUsers*40
   sh = 410+numUsers*25
   
   if(sw > 900) then
   		sw = 900
   	end
   	
   	if(sh > 600) then
   		sh = 600
   	end
   
   numPlanets = 22+numUsers*2.5
   --data.zapCost = 40
   data.resetCost = 15
   data.zapTimer = 0
   data.lastOwner = GAME.game.neutral
   
	data.randPlanet = g2.new_planet(neutral,sw/2,sh/2,150,0)
	data.randPlanet.planet_r = 75
	data.randPlanet.title_value = "Zap"
	data.randPlanet.ships_production = 0
	
	

	
 
   
   for i=1,numPlanets do
        local x = math.random(0,sw)
        local y = math.random(0,sh)
        local prod = math.random(15,100)
        local cost = math.random(0,50)
        g2.new_planet(neutral, x, y, prod, cost);
   end
    local a = math.random(0,360)
    
--add users home planets to the map
    for i,user in pairs(users) do
        local x,y
        x = sw/2 + (sw/1.3)*math.cos(a*math.pi/180.0)/2.0
        y = sh/2 + (sh/1.3)*math.sin(a*math.pi/180.0)/2.0
        local startProduction = 100
        local startShips = 100
        g2.new_planet(user, x,y, startProduction, startShips);
        a = a + 360/#users
    end

    g2.planets_settle(0,0,sw,sh)
    data.randPlanet.position_x = sw/2
    data.randPlanet.position_y = sh/2
    g2.planets_settle(0,0,sw,sh)
    	
    
    data.randPlanet.planet_r = 35
    data.randPlanet.ships_production = 0
    
	local r = data.randPlanet.planet_r
   	local size = (r*2)*2
	local img = g2.new_image("blackhole", data.randPlanet.position_x, data.randPlanet.position_y, size, size)
	img.image_cx = size/2
	img.image_cy = size/2
	img.render_zindex = -1
	
	--[[
	local rot = 0
	local steps = 20
	local width = 15
	local radius = data.randPlanet.planet_r+width/2+3
	local dots = {}
	for i=0,steps do
		local x = data.randPlanet.position_x+radius*math.cos(rot*(math.pi/180))
		local y = data.randPlanet.position_y+radius*math.sin(rot*(math.pi/180))
		local img = g2.new_image("circle2", x, y, width, width)
		img.image_cx = width/2
		img.image_cy = width/2
		img.render_zindex = -1
		dots[#dots+1] = img
		rot = rot+360/steps 
	end
	data.dots = dots
	--]]
	data.dots = {}

end


---------------------------------------------------------------------------
--LOOP FUNCTION, called every frame during the game
--Needs to be named and have the exact same signature as here
---------------------------------------------------------------------------
mode.loop = function(t)
	
	local data = mode.data
	if(data == nil) then
		stopGame(nil)
		return
	end
	
	data.killTimer = data.killTimer+t
	
	
	
	
	
	
	if(data.randPlanet:owner() ~= GAME.game.neutral) then
		if(data.randPlanet:owner() ~= data.lastOwner) then
			data.lastOwner = data.randPlanet:owner()
			data.zapTimer = 0
			for i,dot in pairs(data.dots) do
				dot:destroy()
			end
			data.dots = {}
		end
		--data.zapTimer = data.zapTimer+t*(data.randPlanet.ships_value/30)
		local ships = data.randPlanet.ships_value
		if(ships < 0) then
			ships = 0
		end
		local fac = 0.5+(math.pow((ships/10),0.63)/2)
		if(fac > 15) then
			fac = 15
		end
		if(fac < 0.5) then
			fac = 0.5
		end
		local user = data.randPlanet:owner()
		--print(data.zapTimer)
		
		data.zapTimer = data.zapTimer+t*fac
		local steps = 20
		local rot = #data.dots*(360/steps)-90
		local width = 15
		local radius = data.randPlanet.planet_r+width/2+3
		local shouldBe = (data.zapTimer/5)*steps
		
		if((#data.dots) < shouldBe) then
			local x = data.randPlanet.position_x+radius*math.cos(rot*(math.pi/180))
			local y = data.randPlanet.position_y+radius*math.sin(rot*(math.pi/180))
			local img = g2.new_image("circle2", x, y, width, width)
			img.image_cx = width/2
			img.image_cy = width/2
			img.render_zindex = -1
			img.render_blend = 1
			img.render_color = user.render_color
			data.dots[#data.dots+1] = img
			
		end
		
		
		if(data.zapTimer > 5)then
			data.zapTimer = 0
		
		
		--get random planet
		local planetsS = g2.search("planet")
		local planets = {}
		for i,planet in pairs(planetsS) do
			if(planet:owner() ~= user) then
				planets[#planets+1] = planet
			end
		end
		
		
		
		if(#planets > 0) then
			--print(fac)
			for i,dot in pairs(data.dots) do
				dot:destroy()
			end
			data.dots = {}
		
			local randIndex = math.random(1,#planets)
			local randomPlanet = planets[randIndex]
			randomPlanet:planet_chown(user)
			if(data.line ~= nil) then
				data.line:destroy()
			end
			data.line = g2.new_line(user.render_color,data.randPlanet.position_x,data.randPlanet.position_y,randomPlanet.position_x,randomPlanet.position_y)
			data.line.render_zindex = -1
			data.killTimer = 0
			
			net_send("","sound","sfx-laser");
			
			if(randomPlanet.ships_value < data.resetCost) then
				randomPlanet.ships_value = data.resetCost
			end
		end
		end
		
	end
	
	if(data.killTimer > 3) then
		if(data.line ~= nil) then
			data.line:destroy()
			data.line = nil
		end
		data.killTimer = 0
	end

	--Finds the winner!
	local planets = g2.search("planet -neutral")
 	local winner = nil
    for i,p in ipairs(planets) do
        local user = p:owner()
        if (winner == nil) then winner = user end
        if (winner ~= user) then data.winT = data.winTime return end
    end
    
    if (winner ~= nil) then
       	data.winT = data.winT - t
        if (data.winT < 0) then
        	if(#data.users > 0) then
            	stopGame(winner)
			end
        end
    else
    	stopGame(nil)
    end
    
    if(#data.users == 0) then
    	stopGame(nil)
    end
    
    
end

end