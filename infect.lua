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

function init_infect()
---------------------------------------------------------------------------
--ADD THE MODE
---------------------------------------------------------------------------
local mode = {}
GAME.mode:addMode(mode,"infect")
mode.description = "Survive the plague!"
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

--local settings = GAME.mode.modeList[GAME.mode.current].settings
local settings = mode.settings

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
    data.enemy = g2.new_user("plague",0x777777)
    data.enemy.user_reveal = true
    data.enemy.user_uid = 10000000
   -- users[#users+1] = data.enemy
	data.maxSpeed = 17
    data.users = users
    data.syncT = 0
    data.syncTime = 0.2
    data.won = false
    
    local numC = numClients()
    if(numC < 8) then
    	data.syncTime = 0.14
    elseif(numC > 14 and numC < 20) then
    	data.syncTime = 0.2
    elseif(numC >= 20 and numC < 30) then
    	data.syncTime = 0.3
    elseif(numC >= 30) then
      	data.syncTime = 0.5
    end
    
  --  print("Syncing every: "..data.syncTime .." seconds.")
    
    
    data.enemy.planet_style = json.encode({ 
         texture="tex7w",lighting=false,normal=false,  
         overdraw = {texture="tex7w", ambient=false,addition=false} 
    })
    
    local users1 = g2.search("user")
    
    for i,u in pairs(users1) do
    	u.fleet_crash = 100
    end
    

    mode.data = data

    local settings = mode.settings
    local sw = 750
    local sh = 450
    data.sw = sw
    data.sh = sh
    local MAX_SPEED = data.maxSpeed

    if(#users == 2) then
    -- make a symmetric map
    local numPlanets = 38
        for i=1,numPlanets/2 do
            local x = sw/2 + math.random(-(sw)/2,(sw)/2)
            local y = sh/2 + math.random(-(sh)/2,(sh)/2)
            local prod = math.random(15,100)
            local cost = math.random(0,30)
            local p = g2.new_planet(neutral, x, y, prod, cost)
            p.has_motion = true
            p.has_physics = true
            p.motion_vx = MAX_SPEED*(2*math.random() - 1)*math.cos(p.position_x*p.position_y)
            p.motion_vy = MAX_SPEED*(2*math.random() - 1)*math.sin(p.position_x*p.position_y)
            
            p = g2.new_planet(neutral, sw - x, sh - y, prod, cost)
            p.has_motion = true
            p.has_physics = true
            p.motion_vx = MAX_SPEED*(2*math.random() - 1)*math.cos(p.position_x*p.position_y)
            p.motion_vy = MAX_SPEED*(2*math.random() - 1)*math.sin(p.position_x*p.position_y)
        end
    else
        local numPlanets = 38
        for i=1,numPlanets do
            local x = math.random(0,sw)
            local y = math.random(0,sh)
            local prod = math.random(15,100)
            local cost = math.random(0,30)
            local p = g2.new_planet(neutral, x, y, prod, cost)
            p.has_motion = true
            p.has_physics = true
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
        local startProduction = 100
        local startShips = 100
        local p = g2.new_planet(user, x,y, startProduction, startShips)
        p.has_motion = true
        p.has_physics = true
	    p.motion_vx = MAX_SPEED*(2*math.random() - 1)*math.cos(p.position_x*p.position_y)
        p.motion_vy = MAX_SPEED*(2*math.random() - 1)*math.sin(p.position_x*p.position_y)
        a = a + 360/#users
    end
    local numUsers = #users
    local p = g2.new_planet(data.enemy,sw/2,sh/2,150,numUsers*200)
     p.has_motion = true
     p.has_physics = true
    -- p.motion_vx = MAX_SPEED*(2*math.random() - 1)*math.cos(p.position_x*p.position_y)
      --  p.motion_vy = MAX_SPEED*(2*math.random() - 1)*math.sin(p.position_x*p.position_y)
    
    g2.view_set(0, 0, sw, sh)
    g2.bounds_set(0, 0, sw, sh)
    g2.planets_settle(0, 0, sw, sh)	
    
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
		return
	end
	data.syncT = data.syncT+t
	
	if(data.won == false) then
	local enemyPlanets = g2.search("planet owner:"..data.enemy)
	local otherPlanets = g2.search("planet -owner:"..data.enemy)

	
	for i,enemyPlanet in pairs(enemyPlanets) do
		for i,otherPlanet in pairs(otherPlanets) do
			if(enemyPlanet:distance(otherPlanet) <= enemyPlanet.planet_r+otherPlanet.planet_r+0.1) then
				otherPlanet:planet_chown(data.enemy)
			end
		end
	end
		
	-- check for collisions
	for i,p1 in ipairs(g2.search("planet")) do
		for j,p2 in ipairs(g2.search("planet")) do
		    if j > i then 
                if p1:distance(p2) < p1.planet_r + p2.planet_r then
                    -- collision angle
                    local a = math.atan2(p1.position_y - p2.position_y, p1.position_x - p2.position_x)
                    -- masses of planets
                    local m1 = p1.planet_r*p1.planet_r*p1.planet_r
                    local m2 = p2.planet_r*p2.planet_r*p2.planet_r
                    -- first push the planets to an acceptable distance
                    local distance_to_move = p1.planet_r + p2.planet_r - g2.distance(p1, p2)
                    p1.position_x = p1.position_x + distance_to_move/2*math.cos(a)
                    p2.position_x = p2.position_x - distance_to_move/2*math.cos(a)
                    p1.position_y = p1.position_y + distance_to_move/2*math.sin(a)
                    p2.position_y = p2.position_y - distance_to_move/2*math.sin(a)
                    -- magnitudes of velocities
                    local v1 = math.sqrt(p1.motion_vx*p1.motion_vx + p1.motion_vy*p1.motion_vy)
                    local v2 = math.sqrt(p2.motion_vx*p2.motion_vx + p2.motion_vy*p2.motion_vy)
                    -- directions of velocities
                    local d1 = math.atan2(p1.motion_vy, p1.motion_vx)
                    local d2 = math.atan2(p2.motion_vy, p2.motion_vx)
                    -- velocity components in rotated coordinate system
                    local v1x = v1 * math.cos(d1 - a)
                    local v1y = v1 * math.sin(d1 - a)
                    local v2x = v2 * math.cos(d2 - a)
                    local v2y = v2 * math.sin(d2 - a)
                    -- final x velocities in rotated coordinate system
                    local f1x = (v1x*(m1 - m2) + 2*m2*v2x)/(m1 + m2)
                    local f2x = (v2x*(m2 - m1) + 2*m1*v1x)/(m1 + m2)
                    -- new velocities of planets
                    v1 = math.sqrt(f1x*f1x + v1y*v1y) 
                    v2 = math.sqrt(f2x*f2x + v2y*v2y)
                    -- new directions of planets
                    d1 = math.atan2(v1y, f1x) + a
                    d2 = math.atan2(v2y, f2x) + a
                    p1.motion_vx = v1*math.cos(d1)
                    p1.motion_vy = v1*math.sin(d1)
                    p2.motion_vx = v2*math.cos(d2)
                    p2.motion_vy = v2*math.sin(d2)
                end
            end
		end
	end
	
	local max_speed = data.maxSpeed
	--
	-- make sure velocities are less than the max
	for i,p in ipairs(g2.search("planet")) do
		local vx = p.motion_vx
		local vy = p.motion_vy
		local speed = math.sqrt(vx*vx + vy*vy)
		if speed > max_speed*1.5 then
			p.motion_vx = p.motion_vx * max_speed*1.5 / speed
			p.motion_vy = p.motion_vy * max_speed*1.5 / speed
		end
	end
		end

	
	
	if(data.syncT > data.syncTime) then
		data.syncT = 0

		for i,p in ipairs(g2.search("planet")) do
			p:sync()
		end
	end
    --
    
    -- TEMPORARY: make sure all planets are inside map boundary
    local sw = data.sw
    local sh = data.sh
	for _i,p in ipairs(g2.search("planet")) do
		if p.position_x < 0 then
			p.position_x = 0
			p.motion_vx = -p.motion_vx
		end
		if p.position_x > sw then
			p.position_x = sw
			p.motion_vx = -p.motion_vx
		end
		if p.position_y < 0 then
			p.position_y = 0
			p.motion_vy = -p.motion_vy
		end
		if p.position_y > sh then
			p.position_y = sh
			p.motion_vy = -p.motion_vy
		end
	end

	--Finds the winner!
	local planets = g2.search("planet -neutral")
 	local winner = nil
    for i,p in ipairs(planets) do
    	local user = p:owner()
    	 if(user ~= data.enemy) then

      	if (winner == nil) then winner = user end
      	  	if (winner ~= user) then data.winT = data.winTime return end
        end
    end
    
    if (winner ~= nil) then
			if(data.won == false) then
				net_send("","sound","sfx-dropin")
				data.won = true
				for j,planet in ipairs(g2.search("planet")) do
					planet.motion_vx = 0
					planet.motion_vy = 0
					planet:sync()
				end
				--draw lines
				--render_zindex
				--[[
				for j,planet in ipairs(g2.search("planet")) do
					planet.motion_vx = 0
					planet.motion_vy = 0
					planet:sync()
					if(planet:owner() ~= winner and planet:owner() ~= GAME.game.neutral) then
				    	local line = g2.new_line(winner.render_color,p.position_x,p.position_y,planet.position_x,planet.position_y)
				    	line.render_zindex = -1
				    end
				end
				--]]
				local users = g2.search("user")
				for j,user in pairs(users) do
					if(user ~= winner) then
						surrender(user.user_uid)
					end
				end
	end
    	
       	data.winT = data.winT - t
        if (data.winT < 0) then
        	if(#data.users > 0) then
            	stopGame(winner)
			end
        end
    else
    	net_send("","message","The Plague killed everybody!")
    	stopGame(nil)
    end
    
    if(#data.users == 0) then
    	stopGame(nil)
    end
    
end

end