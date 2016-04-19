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


function init_landmine()
---------------------------------------------------------------------------
--ADD THE MODE
---------------------------------------------------------------------------
local mode = {}
GAME.mode:addMode(mode,"landmine")
mode.description = "In development, kiddos. "
mode.presets = {}
	
	

mode:addPreset("default","Nothing special.",
{
	neutrals = {24,24},
	neutprod = {15,100},
	neutcost = {0,40},
	startships = {100},
	startprod = {100},
	width = {600},
	height = {400}
})


mode:addPreset("tiny","Four planets are enough bruh.",
{
	neutrals = {4,4},
	neutprod = {30,100},
	neutcost = {0,7},
	startships = {100},
	startprod = {100},
	width = {450},
	height = {300}
})

mode:addPreset("small","Nice and cozy map.",
{
	neutrals = {22,22},
	neutprod = {15,100},
	neutcost = {0,40},
	startships = {100},
	startprod = {100},
	width = {600},
	height = {400},
})

mode:addPreset("medium","One menu medium please.",
{
	neutrals = {32,32},
	neutprod = {15,100},
	neutcost = {0,40},
	startships = {100},
	startprod = {100},
	width = {700},
	height = {450},
})


mode:addPreset("large","For the big boys.",
{
	neutrals = {55,55},
	neutprod = {15,100},
	neutcost = {0,40},
	startships = {100},
	startprod = {100},
	width = {900},
	height = {550},
})

mode:addPreset("huge","The bigger the better.",
{
	neutrals = {100,100},
	neutprod = {15,100},
	neutcost = {0,45},
	startships = {100},
	startprod = {100},
	width = {1100},
	height = {750},
})

mode:addPreset("spacey","I feel the distance.",
{
	neutrals = {24,24},
	neutprod = {15,100},
	neutcost = {0,35},
	startships = {100},
	startprod = {100},
	width = {1100},
	height = {750},
})

mode:addPreset("waffle","Blame waffles for this.",
{
	neutrals = {40,40},
	neutprod = {100,100},
	neutcost = {0,0},
	startships = {1},
	startprod = {100},
	width = {600},
	height = {400},
})

mode:addPreset("1prod","Wait for the prod to hit!",
{
	neutrals = {80,80},
	neutprod = {1,1},
	neutcost = {0,4},
	startships = {100},
	startprod = {1},
	width = {600},
	height = {400},
})

mode:addPreset("million","Look at me, I'm a millionaire!",
{
	neutrals = {25,25},
	neutprod = {15,100},
	neutcost = {0,50},
	startships = {1000000},
	startprod = {200},
	width = {600},
	height = {400},
})


mode:addPreset("fatty","500 prod doesn't mean I'm fat!",
{
	neutrals = {40,40},
	neutprod = {30,500},
	neutcost = {0,100},
	startships = {100},
	startprod = {500},
	width = {2000},
	height = {1400},
})

mode:addPreset("strip","Thinner than a hair.",
{
	neutrals = {20,20},
	neutprod = {15,100},
	neutcost = {0,25},
	startships = {100},
	startprod = {100},
	width = {1200},
	height = {1},
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

--local settings = GAME.mode.modeList[GAME.mode.current].settings
local settings = mode.settings

if(settings["neutrals"][2] > 1000) then
	settings["neutrals"][2] = 1000
end
if(settings["neutrals"][1] > settings["neutrals"][2]) then
	settings["neutrals"][1] = settings["neutrals"][2]
end

if(settings["neutcost"][1] > settings["neutcost"][2]) then
	settings["neutcost"][1] = settings["neutcost"][2]
end

if(settings["neutprod"][1] > settings["neutprod"][2]) then
	settings["neutprod"][1] = settings["neutprod"][2]
end

if(settings["width"][1] > 5000) then
	settings["width"][1] = 5000
elseif(settings["width"][1] < 0) then
	settings["width"][1] = 0
end

if(settings["height"][1] > 5000) then
	settings["height"][1] = 5000
elseif(settings["height"][1] < 0) then
	settings["height"][1] = 0
end

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

mode.data = data



local settings = mode.settings
local sw = settings["width"][1]
local sh = settings["height"][1]

sw = 1000
sh = 600




local numPlanets = math.random(settings["neutrals"][1],settings["neutrals"][2])
   for i=1,7 do
        for j=1,12 do
      		local x = 100+100*i
       		local y = 50*j-24
        	local prod = 100
        	
        	local rand = math.random(0,6)
        	local cost = 0
        	if(rand < 5) then
        		cost = math.random(0,80)
        	elseif(rand == 5) then
        		cost = math.random(0,10)
        	elseif(rand == 6) then
        		cost = math.random(80,200)
        	end
     		g2.new_planet(neutral, x, y, prod, cost);
     	end
   end
   
   local finalPlanet = g2.new_planet(neutral, 930, 300, 200, 0)
   
   local r = finalPlanet.planet_r
   local size = (r*2)*0.7
	local black_hole = g2.new_image("icon-trophy", finalPlanet.position_x, finalPlanet.position_y, size, size)
	black_hole.image_cx = size/2
	black_hole.image_cy = size/2
    local a = math.random(0,360)
    
    data.finalPlanet = finalPlanet
    local numUsers = 0
     for i,user in pairs(users) do
     
     	numUsers = numUsers+1
     end
--add users home planets to the map
    for i,user in pairs(users) do
        local x,y
        x = 50
        y = (i)*(sh/numUsers)-35
        local startProduction = settings["startprod"][1]
        local startShips = settings["startships"][1]
        g2.new_planet(user, x,y, startProduction, startShips);
    end
    
    GAME.game.neutral.fleet_crash = 100

    


   for i=1,17 do
      	local x = -20
       	local y = 35*i
        local prod = 100
        local cost = math.random(0,100)
     	g2.new_planet(neutral, x, y, 50, 0);
   end
   
    for i=1,17 do
      	local x = sw+20
       	local y = 35*i
        local prod = 100
        local cost = math.random(0,100)
     	g2.new_planet(neutral, x, y, 50, 0);
   end
   
   for i=1,30 do
      	local x = 35*i
       	local y = -10
        local prod = 100
        local cost = math.random(0,100)
     	g2.new_planet(neutral, x, y, 50, 0);
   end
   
   for i=1,30 do
      	local x = 35*i
       	local y = sh+10
        local prod = 100
        local cost = math.random(0,100)
     	g2.new_planet(neutral, x, y, 50, 0);
   end
   

  --  g2.planets_settle(0,0,GAME.sw,GAME.sh)	
	
	local planets = g2.search("planet")
	local planetData = {}
	for i,planet in pairs(planets) do
		local pData = {}
		pData.mine = false
		pData.origOwner = planet:owner()
		
		
		if(planet:owner() ~= GAME.game.neutral) then
			pData.home = true
			planet.ui_to_mask = 0x2
		else
			pData.home = false
		end
		
		if(planet:owner() == GAME.game.neutral and planet ~= finalPlanet) then
			local ships = planet.ships_value
			local value = 1+ships/10
			planet.title_value = tostring(math.floor((1/(value+1))*100)).."%"

			if(math.random(0,value) == 0) then
				pData.mine = true
			end
			if(planet.ships_production == 50) then
				pData.mine = false
				planet.title_value = "Border"
			end
		end
		planetData[planet.n] = pData

	end
	data.planetData = planetData
	
	 local raceTrackColor = 0x555555
    g2.new_line(raceTrackColor,0,0,0,sh)
    g2.new_line(raceTrackColor,sw,0,sw,sh)
    g2.new_line(raceTrackColor,0,0,sw,0)
    g2.new_line(raceTrackColor,0,sh,sw,sh)
    

   
end


---------------------------------------------------------------------------
--LOOP FUNCTION, called every frame during the game
--Needs to be named and have the exact same signature as here
---------------------------------------------------------------------------
mode.loop = function(t)
	
	local data = mode.data
	if(data == nil) then
		stopGame(nil)
		local data = {}
		data.winTime = 5
		data.winT = data.winTime
		data.users = g2.search("user")
		mode.data = data
		return
	end
	
	local planets = g2.search("planet")
	for i,planet in pairs(planets) do
		local pData = data.planetData[planet.n]
		
		if(planet.ships_production == 50) then
			if(planet:owner() ~= GAME.game.neutral) then
				planet:planet_chown(GAME.game.neutral)
				planet.ships_value = 0
			end
		end
		
		if(pData.home == true and planet:owner() ~= pData.origOwner and planet:owner() ~= GAME.game.neutral) then
				planet:planet_chown(pData.origOwner)
				planet.ships_value = 1
				--surrender(planet:owner().user_uid)
				--local r = planet.planet_r
				--local size = r*2
				--local black_hole = g2.new_image("icon-rival", planet.position_x, planet.position_y, size, size)
				--black_hole.image_cx = size/2
				--black_hole.image_cy = size/2
				--pData.mine = true
		end
		
		if(pData.mine == true) then
			if(planet:owner() ~= GAME.game.neutral) then
				
   			 	local user = planet:owner()

    		if user == nil then return end

    		for n,e in pairs(g2.search("planet owner:"..user)) do
    			local pData = data.planetData[e.n]
    			if(pData.home == false) then
       				 e:planet_chown(GAME.galcon.neutral)
       			 end
   			 end
    
    		for n,e in pairs(g2.search("fleet owner:"..user)) do
       			 e:destroy() 
   			 end
				
				local r = planet.planet_r
				local size = r*2
				local black_hole = g2.new_image("icon-rival", planet.position_x, planet.position_y, size, size)
				black_hole.image_cx = size/2
				black_hole.image_cy = size/2
				--black_hole.render_zindex = -1
			end	
		end
	end
	
	
	if(data.finalPlanet:owner() ~= GAME.game.neutral) then
		local winner = data.finalPlanet:owner()
	for j,planet in ipairs(g2.search("planet")) do
					
				
				
					if(planet:owner() ~= winner and planet:owner() ~= GAME.game.neutral) then
				    	local line = g2.new_line(winner.render_color,data.finalPlanet.position_x,data.finalPlanet.position_y,planet.position_x,planet.position_y)
				    	line.render_zindex = -1
				    end
	end
		for j,user in pairs(data.users) do
					if(user ~= winner) then
						surrender(user.user_uid)
					end
				end
	end
	

	--Finds the winner!
	planets = g2.search("planet -neutral")
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