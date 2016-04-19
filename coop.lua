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


function init_coop()
---------------------------------------------------------------------------
--ADD THE MODE
---------------------------------------------------------------------------
local mode = {}
GAME.mode:addMode(mode,"coop")
mode.description = "Endure! "
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
data.bot = g2.new_user("enemy",0x555555)
data.botHome = nil
data.amountToSend = 0
data.amountSent = 0
data.waveTime = 29
data.waveNumber = 0
data.sendTime = 0
data.maxSendTime = 0

mode.data = data

local padding = 160

local settings = mode.settings
local sw = 700
local sh = 450

local numUsers = #users

local numPlanets = math.random(settings["neutrals"][1],settings["neutrals"][2])
numPlanets = 28

local totalProd = 0
local totalCost = 0
local requiredProd = 2000
local requiredCost = 1500


local numNeutrals = numPlanets-numUsers
if(numNeutrals < 0) then
	numNeutrals = 0
end
   for i=1,100 do
   		if(totalProd < requiredProd) then
        	local x = math.random(0,sw-padding)
       		local y = math.random(0,sh)
        	local prod = math.random(30,130)
       		totalProd = totalProd+prod
       		local cost = math.random(0,150)
       		if(totalCost > requiredCost) then
       			cost = 0
       		end
       		totalCost = totalCost+cost
       		g2.new_planet(neutral, x, y, prod, cost);
        end
   end
   
    local a = math.random(0,360)
    
    
    local planets = g2.search("planet")
--add users home planets to the map
    for i,user in pairs(users) do
        local x = math.random(0,sw-padding)
        local y = math.random(0,sh)
        local prod = 400/numUsers
        local ships = 400/numUsers
        g2.new_planet(user, x, y, prod, ships);
        user.user_team_n = 2
    end
    

    g2.planets_settle(0,0,sw-padding,sh)
    g2.view_set(50,0,sw,sh)
   	data.botHome = g2.new_planet(data.bot,sw+300,sh/2,0,0)


end

--[[
function sendExact(user, from, to, ships)
            if from.ships_value < ships then
                from:fleet_send(100, to)
                return from.ships_value
            end
            local perc = ships / from.ships_value * 100
            if perc > 100 then perc = 100 end
            if(to ~= nil) then
            from:fleet_send(perc, to)
            end
            return ships
end
--]]

function wave4Redirect(data)
local fleets = g2.search("fleet")
local fleetData = {}
for i,fleet in pairs(fleets) do
	local fData = {}
	fData.fleet = fleet
	fData.targetX = 0
	fData.targetY = 0
	fData.hasTarget = true
	fleetData[fleet.n] = fData
end

local userFleets = g2.search("fleet owner:"..data.bot)


for i,userFleet1 in pairs(userFleets) do
		for j=i+1,#userFleets do
		if(j < #userFleets) then
		local userFleet2 = userFleets[j]

		local diffX = userFleet2.position_x-userFleet1.position_x
		local diffY = userFleet2.position_y-userFleet1.position_y
		local dist = math.sqrt(diffX*diffX+diffY+diffY)
		if(dist ~= 0) then
			diffX = diffX/dist
			diffY = diffY/dist
		else
			print("hi")
		end
		if(dist < 10) then
			local fData = fleetData[userFleet1.n]
			if(fData.hasTarget == true) then
				fData.targetX = fData.targetX-diffX*10
				fData.targetY = fData.targetY-diffY*10
			end
			--redirectFleet(userFleet1,userFleet1.position_x-diffX*100,userFleet1.position_y-diffY*100)
		end
		end
	end
end

for i,fData in pairs(fleetData) do
	if(fData.hasTarget == true) then
		redirectFleet(fData.fleet,fData.targetX,fData.targetY)
	end
end


end


function redirectFleet(fleet,x,y)
			if(fleet ~= nil) then
				local target_planet_data = GAME.planet_data[fleet.fleet_target]
				local closest = nil
				local dist = 999999999999
				
				local deltaX = fleet.position_x-x
				local deltaY = fleet.position_y-y
				local angleDiffCoor = math.atan2(deltaY, deltaX) * 180 / math.pi
				local smallestDiff = 99999999
				local smallestDiffPlanet = nil
				for i,p in pairs (GAME.planets) do
					local planetData = GAME.planet_data[p.n]

					deltaX = fleet.position_x-planetData.planet.position_x
					deltaY = fleet.position_y-planetData.planet.position_y
					local angleDiffPlanet = math.atan2(deltaY, deltaX) * 180 / math.pi
					if(math.abs(angleDiffPlanet-angleDiffCoor) < smallestDiff and fleet:distance(planetData.planet) > planetData.planet.planet_r+15) then
						smallestDiff = math.abs(angleDiffPlanet-angleDiffCoor)
						smallestDiffPlanet = planetData.planet
					end
				end
		
                
		 		fleet:fleet_redirect(smallestDiffPlanet)
		 	end
end

function planetValue(p,fleet,data) 
	local dist = fleet:distance(p)
     if(p:owner() == data.bot) then
     	dist = 100000
     end
     
     local distValue = -dist
     local shipsValue = -p.ships_value*8
      
     local value = distValue+shipsValue		
      -- print("DIST:",distValue)
     --  print("SHIPS:",shipsValue)
   	return value

end

---------------------------------------------------------------------------
--LOOP FUNCTION, called every frame during the game
--Needs to be named and have the exact same signature as here
---------------------------------------------------------------------------
mode.loop = function(t)
	
	local data = mode.data
	if(data == nil) then
		local data = {}
		stopGame(nil)
		return
	end
	

	data.waveTime = data.waveTime+t
	if(data.waveTime > 30) then
		data.waveTime = 0
		data.amountSent = 0
		
		data.waveNumber = data.waveNumber+1
		net_send("","message","== WAVE #"..data.waveNumber.." ==")
		if(data.waveNumber == 1) then
			data.amountToSend = 100
		elseif(data.waveNumber == 2) then
			data.amountToSend = 200
		elseif(data.waveNumber == 3) then
			data.amountToSend = 300
		elseif(data.waveNumber == 4) then
			data.amountToSend = 400
		end
		data.amountToSend = data.waveNumber*100+((data.waveNumber+5)*(data.waveNumber+5)*3)-50
	end
	
	if(data.botHome.ships_value < data.amountToSend) then
		data.botHome.ships_value = data.amountToSend*2
	end
	
	local planets = g2.search("planet -neutral")
	data.sendTime = data.sendTime+t
	for i,p in pairs(planets) do
		if(data.amountSent < data.amountToSend) then
			if(data.sendTime > data.maxSendTime) then
				data.sendTime = 0
				local amountSent = sendExact(data.bot,data.botHome,p,data.amountToSend/25)
				data.amountSent = data.amountSent+amountSent
			end
		end
		
	end
	
	local fleets = g2.search("fleet owner:"..data.bot)
	for i,fleet in pairs(fleets) do
	
				local bestPlanet = find("planet -neutral",
        			function(p)
        				return planetValue(p,fleet,data)
        			end)
        		if(bestPlanet ~= nil) then
        			fleet:fleet_redirect(bestPlanet)
        			 --redirectFleet(fleet,bestPlanet.position_x,bestPlanet.position_y)

        		end
        	

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