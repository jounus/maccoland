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


function init_lazor()
---------------------------------------------------------------------------
--ADD THE MODE
---------------------------------------------------------------------------
local mode = {}
GAME.mode:addMode(mode,"lazor")
mode.description = "Everyone against everyone! "
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
   numPlanets = 22+numUsers*2.5

	
 data.middlePlanet = g2.new_planet(neutral,sw/2,sh/2,100,math.random(0,50))
   
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
    	user.fleet_crash = 100
        local x,y
        x = sw/2 + (sw/1.3)*math.cos(a*math.pi/180.0)/2.0
        y = sh/2 + (sh/1.3)*math.sin(a*math.pi/180.0)/2.0
        local startProduction = 100
        local startShips = 100
        g2.new_planet(user, x,y, startProduction, startShips);
        a = a + 360/#users
    end

    g2.planets_settle(0,0,sw,sh)
   -- data.randPlanet.position_x = sw/2
    --data.randPlanet.position_y = sh/2
    --g2.planets_settle(0,0,sw,sh)
    	

	
	data.fleetZapLine = nil
	data.fleetTime = 0
	
	data.lastZapped = data.middlePlanet
	data.lazorPlanet = data.middlePlanet
	data.lazorTime = 0
	
	data.circle1 = g2.new_circle(0xFFFFFF, data.lazorPlanet.position_x, data.lazorPlanet.position_y, data.lazorPlanet.planet_r)
	data.circle2 = nil
	
	data.lazorTimeMax = 8
	

end

function randPlanet()
	local planets = g2.search("planet")
	local planetList = {}
	for i,planet in pairs(planets) do
		if(planet:owner() ~= GAME.game.neutral) then
			planetList[#planetList+1] = planet
			
		end
	end
	local randIndex = math.random(1,#planetList)
	local randPlanet1 = planetList[randIndex]
	return randPlanet1;
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
	data.lazorTime = data.lazorTime+t
	data.fleetTime = data.fleetTime+t
	
	
	if(data.fleetTime > 10000) then
		data.fleetTime = 0
		local bestFleet = find("fleet",
        		function(f)    			
        			local dist = data.lazorPlanet:distance(f)
        			return -dist
        		end)
     
        
      
		
		if(bestFleet ~= nil) then
			if(data.lazorPlanet:distance(bestFleet) < 150) then
			if(data.fleetZapLine ~= nil) then
				data.fleetZapLine:destroy()
				data.fleetZapLine = nil
			end
			data.fleetZapLine = g2.new_line(0xFFFFFF,data.lazorPlanet.position_x,data.lazorPlanet.position_y,bestFleet.position_x,bestFleet.position_y)
			data.fleetZapLine.render_zindex = -1
        	bestFleet:destroy()
        	net_send("","sound","sfx-laser");
			end
        end
	end

	
	
	if(data.lazorTime > data.lazorTimeMax) then
		data.lazorTimeMax = 3
		local planets = g2.search("planet")
		local numPlanets = 0
		for i,planet in pairs(planets) do
			 numPlanets = numPlanets+1
		end
		if(numPlanets > 1) then
		data.lazorTime = 0
		local randomPlanet = find("planet",
        		function(p)
        			if(p:owner() == GAME.game.neutral or p == data.lazorPlanet or p == data.lastZapped) then
        				return -10000
        			end	
        			
        			local dist = data.lazorPlanet:distance(p)
        			return -dist
        		end)


		randomPlanet:planet_chown(GAME.game.neutral)
		randomPlanet.ships_value = math.random(0,50)
		if(data.line ~= nil) then
			data.line:destroy()
		end
		if(data.circle1 ~= nil) then
			data.circle1:destroy()
		end
		if(data.circle2 ~= nil) then
			data.circle2:destroy()
		end
			data.line = g2.new_line(0xFFFFFF,data.lazorPlanet.position_x,data.lazorPlanet.position_y,randomPlanet.position_x,randomPlanet.position_y)
			data.line.render_zindex = -1
			data.killTimer = 0
			data.lastZapped = data.lazorPlanet
			data.lazorPlanet = randomPlanet
			
			data.circle1 = g2.new_circle(0xFFFFFF, data.lazorPlanet.position_x, data.lazorPlanet.position_y, data.lazorPlanet.planet_r)
			data.circle2 = g2.new_circle(0xFFFFFF, data.lastZapped.position_x, data.lastZapped.position_y, data.lastZapped.planet_r)
			
			net_send("","sound","sfx-laser");
		end
	end
	
	
	if(data.killTimer > 2) then
		if(data.fleetZapLine ~= nil) then
			data.fleetZapLine:destroy()
			data.fleetZapLine = nil
		end
		data.killTimer = 0
	end

	
	--[[
	if(data.randPlanet:owner() ~= GAME.game.neutral) then
		local user = data.randPlanet:owner()
		data.randPlanet:planet_chown(GAME.game.neutral)
		data.randPlanet.ships_value = data.zapCost
		local planetsS = g2.search("planet -neutral")
		local planets = {}
		for i,planet in pairs(planetsS) do
			if(planet:owner() ~= user) then
				planets[#planets+1] = planet
			end
		end
		if(#planets > 0) then
			local randIndex = math.random(1,#planets)
			local randomPlanet = planets[randIndex]
			randomPlanet:planet_chown(GAME.game.neutral)
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
	--]]
	--[[
	if(data.killTimer > 3) then
		if(data.line ~= nil) then
			data.line:destroy()
			data.line = nil
		end
		data.killTimer = 0
	end
	--]]

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
    	--stopGame(nil)
    end
    
    
end

end