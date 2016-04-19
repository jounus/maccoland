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

function init_cell()
---------------------------------------------------------------------------
--ADD THE MODE
---------------------------------------------------------------------------
local mode = {}
GAME.mode:addMode(mode,"cell")
mode.description = "Planets eat each other! "
mode.presets = {}
	

mode:addPreset("default","Nothing special.",
{
	neutrals = {24,24},
	neutprod = {15,100},
	neutcost = {0,40},
	startships = {100},
	startprod = {100},
	width = {600},
	height = {400},
	maxspeed = {35},
})


mode:addPreset("tiny","Four planets are enough bruh.",
{
	neutrals = {4,4},
	neutprod = {30,100},
	neutcost = {0,7},
	startships = {100},
	startprod = {100},
	width = {450},
	height = {300},
	maxspeed = {35},
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
	maxspeed = {35},
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
	maxspeed = {35},
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
	maxspeed = {35},
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
	maxspeed = {35},
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
	maxspeed = {35},
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
	maxspeed = {35},
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
	maxspeed = {35},
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
	maxspeed = {35},
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
	maxspeed = {35},
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
	maxspeed = {35},
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

-- make sure max speed is >= 0
if(settings["maxspeed"][1] < 0) then
    settings["maxspeed"][1] = 0
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
    local MAX_SPEED = settings["maxspeed"][1]

    if(#users == 2) then
    -- make a symmetric map
    local numPlanets = math.random(settings["neutrals"][1],settings["neutrals"][2])
        for i=1,numPlanets/2 do
            local x = sw/2 + math.random(-(sw)/2,(sw)/2)
            local y = sh/2 + math.random(-(sh)/2,(sh)/2)
            local prod = math.random(settings["neutprod"][1],settings["neutprod"][2])
            local cost = math.random(settings["neutcost"][1],settings["neutcost"][2])
            local p = g2.new_planet(neutral, x, y, prod, cost)
            p.has_motion = true
            p.motion_vx = MAX_SPEED*(2*math.random() - 1)*math.cos(p.position_x*p.position_y)
            p.motion_vy = MAX_SPEED*(2*math.random() - 1)*math.sin(p.position_x*p.position_y)
            
            local p2 = g2.new_planet(neutral, sw - x, sh - y, prod, cost)
            p2.has_motion = true
            p2.motion_vx = -p.motion_vx
            p2.motion_vy = -p.motion_vy
        end
    else
        local numPlanets = math.random(settings["neutrals"][1],settings["neutrals"][2])
        for i=1,numPlanets do
            local x = math.random(0,sw)
            local y = math.random(0,sh)
            local prod = math.random(settings["neutprod"][1],settings["neutprod"][2])
            local cost = math.random(settings["neutcost"][1],settings["neutcost"][2])
            local p = g2.new_planet(neutral, x, y, prod, cost)
            p.has_motion = true
            p.motion_vx = MAX_SPEED*(2*math.random() - 1)*math.cos(p.position_x*p.position_y)
            p.motion_vy = MAX_SPEED*(2*math.random() - 1)*math.sin(p.position_x*p.position_y)
        end
    end
        
    local a = math.random(0,360)
    --add users home planets to the map
    for i,user in pairs(users) do
        local x,y
        x = sw/2 + (sw/1.3)*math.cos(a*math.pi/180.0)/2.0
        y = sh/2 + (sh/1.3)*math.sin(a*math.pi/180.0)/2.0
        local startProduction = settings["startprod"][1]
        local startShips = settings["startships"][1]
        local p = g2.new_planet(user, x,y, startProduction, startShips)
        p.has_motion = true
	    p.motion_vx = MAX_SPEED/4*math.cos(a*300 + math.floor(a/180))
        p.motion_vy = MAX_SPEED/4*math.sin(a*300 + math.floor(a/180))
        a = a + 360/#users
    end
    
    g2.view_set(0, 0, sw, sh)
    g2.bounds_set(0, 0, sw, sh)
    g2.planets_settle(0, 0, sw, sh)	

end

---------------------------------------------------------------------------
--LOOP FUNCTION, called every frame during the game
--Needs to be named and have the exact same signature as here
---------------------------------------------------------------------------

mode.loop = function(t)
	local data = mode.data
	if(data == nil) then
		local data = {}
		data.winTime = 5
		data.winT = data.winTime
		data.users = g2.search("user")
		mode.data = data
		return
	end
		
	-- check for collisions
	local planets = g2.search("planet")
	for i,p1 in ipairs(planets) do
		for j,p2 in ipairs(planets) do
		    if (j > i) then
                if p1:distance(p2) < p1.planet_r + p2.planet_r then
                    local overlap = p1.planet_r + p2.planet_r - g2.distance(p1, p2)
                    local smaller = p1
                    local bigger = p2
                    if (p1.ships_value > p2.ships_value) then
                        smaller = p2
                        bigger = p1
                    end
                    local mass = function(p) return p.planet_r*p.planet_r end
                    local mS = mass(smaller)
                    local mB = mass(bigger)
                    -- eat the planet
                    local old_production = smaller.ships_production
                    if (smaller.planet_r - overlap < 10) then
                        smaller.planet_r = 0
                        smaller.ships_production = 0
                        smaller.position_x = bigger.position_x
                        smaller.position_y = bigger.position_y
                        bigger.ships_value = bigger.ships_value + smaller.ships_value
                        -- add momentums
                        --bigger.motion_vx = (bigger.motion_vx * mB + smaller.motion_vx * mS) / (mB + mS)
                        --bigger.motion_vy = (bigger.motion_vy * mB + smaller.motion_vy * mS) / (mB + mS)
                        for j,f in ipairs(g2.search("fleet")) do
	                        if (f.fleet_target == smaller.n) then
	                            f:fleet_redirect(bigger)
	                        end
	                    end
                    -- just start to absorb
                    else 
                        smaller.planet_r = smaller.planet_r - overlap
                        smaller.ships_production = (smaller.planet_r - 15)*17/3 + 15
                        local mass_lost = mS - mass(smaller)
                        local ships_transferred = mass_lost/mS*smaller.ships_value
                        smaller.ships_value = smaller.ships_value - ships_transferred
                        bigger.ships_value = bigger.ships_value + ships_transferred
                        
                        --smaller.motion_vx = (bigger.motion_vx * mass_lost + smaller.motion_vx * mass(smaller)) / (mS)
                        --smaller.motion_vy = (bigger.motion_vy * mass_lost + smaller.motion_vy * mass(smaller)) / (mS)
                        -- add momentums
                        --bigger.motion_vx = (bigger.motion_vx * mB + smaller.motion_vx * mass_lost) / (mB + mass_lost)
                        --bigger.motion_vy = (bigger.motion_vy * mB + smaller.motion_vy * mass_lost) / (mB + mass_lost)
                     end
                    -- add areas.. not radii or masses
                    bigger.planet_r = math.pow(mB + mS - mass(smaller), 1/2)
                    bigger.ships_production = 17/3*(bigger.planet_r - 15) + 15
                     -- collision angle
                     if (bigger.position_x ~= smaller.position_x and bigger.position_y ~= smaller.position_y) then
                        local a = math.atan2(bigger.position_y - smaller.position_y, bigger.position_x - smaller.position_x)
                        -- first push the planets to an acceptable distance
                        local distance_to_move = bigger.planet_r + smaller.planet_r - g2.distance(bigger, smaller)
                        smaller.position_x = smaller.position_x - distance_to_move*math.cos(a)
                        smaller.position_y = smaller.position_y - distance_to_move*math.sin(a)
                    end
                end
            end
		end
	end
	-- clean up eaten planets
	for i,p1 in ipairs(g2.search("planet")) do
	    if (p1.planet_r == 0) then
	        p1:destroy()
	    else
	        p1:sync()
	    end
	end
	
	local max_speed = mode.settings["maxspeed"][1]
	--[[
	-- make sure velocities are less than the max
	for i,p in ipairs(g2.search("planet")) do
		local vx = p.motion_vx
		local vy = p.motion_vy
		local speed = math.sqrt(vx*vx + vy*vy)
		if speed > max_speed then
			p.motion_vx = p.motion_vx * max_speed / speed
			p.motion_vy = p.motion_vy * max_speed / speed
		end
	end
    --]]
    
    -- TEMPORARY: make sure all planets are inside map boundary
    local sw = mode.settings["width"][1]
    local sh = mode.settings["height"][1]
	for _i,p in ipairs(g2.search("planet")) do
		if p.position_x < p.planet_r then
			p.position_x = p.planet_r
			p.motion_vx = math.max(p.motion_vx, -p.motion_vx)
		end
		if p.position_x > sw - p.planet_r then
			p.position_x = sw - p.planet_r
			p.motion_vx = math.min(p.motion_vx, -p.motion_vx)
		end
		if p.position_y < p.planet_r then
			p.position_y = p.planet_r
			p.motion_vy = math.max(p.motion_vy, -p.motion_vy)
		end
		if p.position_y > sh - p.planet_r then
			p.position_y = sh - p.planet_r
			p.motion_vy = math.min(p.motion_vy, -p.motion_vy)
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