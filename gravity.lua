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

function init_gravity()
---------------------------------------------------------------------------
--ADD THE MODE
---------------------------------------------------------------------------
local mode = {}
GAME.mode:addMode(mode,"gravity")
mode.description = "Bruh, I'm still makin it."
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
    data.users = users
    data.userData = {}
    data.planetData = {}
    data.planetTime = 0
    data.maxPlanetTime = 5
    data.speed = 10
    data.won = false
    data.syncT = 0
    data.syncTime = 0.05
    
	local numUsers = #users
    local num = 0
    local sh = 500
    local sw = 800
	local neutBarrier = 250+numUsers*28.5
    local userSpacing = sw/numUsers
    mode.data = data
    

    local settings = mode.settings
    local MAX_SPEED = 10

  
        local numPlanets = 30
        for i=1,numPlanets do
            
            local prod = math.random(15,100)
            local cost = math.random(0,15)
            local x = math.random(0,sw)
            local y = math.random(0,sh/2)
            local p = addRacingPlanet1(GAME.game.neutral,x,y,prod,cost)
            
          
        end
        
        
    local a = math.random(0,360)
    --add users home planets to the map
  	
    for i,user in pairs(users) do
    	user.ui_fleet_redirect = false
    	
    	data.userData[user.user_uid] = {}
    	data.userData[user.user_uid].viewX = 0
    	
        local x,y
        x = 50+num*userSpacing
        y = 100
        local startProduction = 100
        local startShips = 100
        addRacingPlanet1(user,x,y,startProduction,startShips)
        a = a + 360/#users
        num = num+1
        

    end
    
    local raceTrackColor = 0x555555
    g2.new_line(raceTrackColor,0,0,0,sh)
    g2.new_line(raceTrackColor,sw,0,sw,sh)
    g2.new_line(raceTrackColor,0,0,sw,0)
    g2.new_line(raceTrackColor,0,sh,sw,sh)
    --[[
    local black_hole = g2.new_image("icon-play", sw/2, sh/2, 50, 50)
	black_hole.image_cx = 25
	black_hole.image_cy = 25
	black_hole.render_zindex = -1
	--]]
    
    local markHeight = 3
    local markSpacing = 100
    local numMarks = sw/markSpacing
    for i=1,numMarks do
    	g2.new_line(raceTrackColor,i*markSpacing,0,i*markSpacing,markHeight)
    	g2.new_line(raceTrackColor,i*markSpacing,sh,i*markSpacing,sh-markHeight)
    end
    
    g2.view_set(0, 0, sw, sh)
    g2.bounds_set(0, 0, sw, sh)
    data.sw = sw
    data.sh = sh
    g2.planets_settle(0, 0, sw, sh)	
end

function addRacingPlanet1(user, x,y, startProduction, startShips)
	local p = g2.new_planet(user, x,y, startProduction, startShips)
	if(p.position_x-p.planet_r < 0) then
		p.position_x = 0+p.planet_r
	end
	p.has_motion = true
    p.has_physics = true
	p.motion_vx = mode.data.speed

    p.motion_vy = mode.data.speed*0.2*(2*math.random() - 1)
    if(user == GAME.game.neutral) then
		p.motion_vx = 0
		p.motion_vy = 0
	end
	mode.data.planetData[p.n] = {}
	mode.data.planetData[p.n].speed = mode.data.speed
	mode.data.planetData[p.n].origX = p.position_x
	mode.data.planetData[p.n].origY = p.position_y
	mode.data.planetData[p.n].destroyed = false
	return p

end


function deleteRacingPlanet(planet)

end

function acceleration(ships)
	local val = 0.06+ships/305
	return val
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
	data.planetTime = data.planetTime+t
	if(data.planetTime >= data.maxPlanetTime) then
		data.speed = data.speed+5
		data.planetTime = 0
		data.maxPlanetTime = math.random(3,10)
		local x,y
        x = 0
        y = math.random(50,data.sh-50)
        local prod = math.random(15,100)
        local ships = math.random(0,10)
       -- addRacingPlanet(GAME.game.neutral,x,y,prod,ships)
	end
	
	
	local users = data.users
	for i,user in pairs(users) do
		if(user.fleet_v_factor ~= 1.1) then
			user.fleet_v_factor = 1.1
		end
	end

	
	if(data.won == false) then
			
		--[[
		local fleets = g2.search("fleet")
		
		
		for i,p in pairs(g2.search("planet")) do
			--print(data.planetData[p.n].origY)
				local acelX = p.position_x-data.planetData[p.n].origX
				local acelY = p.position_y-data.planetData[p.n].origY
			
				local fac = 0.001
				--p1.motion_vx = p1.motion_vx+acelX*fac
				--p1.motion_vy = p1.motion_vy+acelX*fac
			--	if(p1:distance(p2) < 150+p2.planet_r) then
					p.motion_vx = p.motion_vx-acelX*fac
					p.motion_vy = p.motion_vy-acelY*fac
				--end

			
		end

	
	
		for i,p1 in ipairs(fleets) do
			for j,p2 in ipairs(g2.search("planet")) do
				local acelX = p1.position_x-p2.position_x
				local acelY = p1.position_y-p2.position_y
				local dist = math.sqrt(acelX*acelX+acelY*acelY)
				if(dist ~= 0) then
					acelX = acelX/dist
					acelY = acelY/dist
				end
				local fac = 0.2
				--p1.motion_vx = p1.motion_vx+acelX*fac
				--p1.motion_vy = p1.motion_vy+acelX*fac
				if(p1:distance(p2)+p2.planet_r < 150) then
					p2.motion_vx = p2.motion_vx-acelX*fac
					p2.motion_vy = p2.motion_vy-acelX*fac
				end

			end
		end
	--]]
	
	
	for i,p1 in ipairs(g2.search("planet")) do
		if(data.planetData[p1.n].destroyed == true) then
			if(p1:owner() ~= GAME.game.neutral) then
				p1:planet_chown(GAME.game.neutral)
			end
		end
	end

	
for i,p1 in ipairs(g2.search("planet")) do

	for j,p2 in ipairs(g2.search("planet")) do
              if p1:distance(p2) < p1.planet_r + p2.planet_r+2 then
                if(data.planetData[p1.n].destroyed == true) then
                	if(data.planetData[p2.n].destroyed == false) then
						p2:planet_chown(GAME.game.neutral)
						data.planetData[p2.n].destroyed = true
						--p2.ships_value = 100
					end
					
                end
             if(data.planetData[p2.n].destroyed == true) then

                if(data.planetData[p1.n].destroyed == false) then
						p1:planet_chown(GAME.game.neutral)
						data.planetData[p1.n].destroyed = true
						--p1.ships_value = 100
					end
					
				end
                
     	end
     end
    end
	
	for i,planet in ipairs(g2.search("planet")) do
		if(planet.position_y+planet.planet_r >= data.sh-0.2) then
			if(data.planetData[planet.n].destroyed == false) then
				planet:planet_chown(GAME.game.neutral)
				data.planetData[planet.n].destroyed = true
				--planet.ships_value = 100
			end
		end
	end
	
	for i,p1 in ipairs(g2.search("planet")) do
	
		if(data.planetData[p1.n].destroyed == true) then
			p1.motion_vy = 0
			p1.motion_vx = 0
		end
		--if(data.planetData[p1.n].destroyed == false) then
		--if(p1:owner() ~= GAME.game.neutral) then
			--p1.motion_vx = p1.motion_vx+acceleration(p1.ships_value)
		--else
			--p1.motion_vx = p1.motion_vx+3
		--end
		--if(p1.ships_value > 110) then
		if(p1:owner() ~= GAME.game.neutral) then
			p1.motion_vy = (p1.motion_vy-(p1.ships_value+28)/(25*(1+(GAME.game.time*GAME.game.time)/250)))
	--	end
		--if(p1.ships_value < 100) then
			p1.motion_vy = p1.motion_vy+0.7
		--end
		end
		
		
		p1.motion_vy = p1.motion_vy*0.99
		p1.motion_vx = p1.motion_vx*0.99
		
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
		--end
	end
	
	
	local max_speed = 15
	
	
	
	-- make sure velocities are less than the max
	for i,p in ipairs(g2.search("planet")) do
		local vx = p.motion_vx
		local vy = p.motion_vy
		local speed = math.sqrt(vx*vx + vy*vy)
		
		if speed > max_speed*1.5 then
			p.motion_vx = p.motion_vx * data.planetData[p.n].speed*1.5 / speed
			p.motion_vy = p.motion_vy * data.planetData[p.n].speed*1.5 / speed
		end
		
		--[[
		if speed > data.speed*1.5 then
			p.motion_vx = p.motion_vx * data.speed / speed
			p.motion_vy = p.motion_vy * data.speed / speed
		end
		--]]
		
	end
	
	if(data.syncT > data.syncTime) then
		data.syncT = 0

		for i,p in ipairs(g2.search("planet")) do
			p:sync()
		end
	end
	
	--[[
	-- check for collisions
	local planets = g2.search("planet")
	for i,p1 in ipairs(planets) do
	if(p1:owner() ~= GAME.game.neutral) then
			p1.motion_vx = p1.motion_vx+acceleration(p1.ships_value)
		else
			--p1.motion_vx = p1.motion_vx+3
		end

		
		p1.motion_vx = p1.motion_vx*0.96
	
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
	       -- p1:sync()
	    end
	end
--]]

	end

 -- TEMPORARY: make sure all planets are inside map boundary
	
	--[[
	for i,p in ipairs(g2.search("planet")) do
		
		if(p.position_x+p.planet_r > data.sw) then
			if(data.won == false) then
				net_send("","sound","sfx-dropin")
				data.won = true
				local winner = p:owner()
				winner.user_reveal = true
				winner.ships_production_enabled = 0

				
				--draw lines
				--render_zindex
				for j,planet in ipairs(g2.search("planet")) do
					planet.motion_vx = 0
					planet.motion_vy = 0
					planet:sync()
					if(planet:owner() ~= winner and planet:owner() ~= GAME.game.neutral) then
				    	local line = g2.new_line(winner.render_color,p.position_x,p.position_y,planet.position_x,planet.position_y)
				    	line.render_zindex = -1
				    end
				end
				
				
				for j,user in pairs(data.users) do
					if(user ~= winner) then
						surrender(user.user_uid)
					end
				end
			end
		end
	end

	--]]

	
	 local sw = data.sw
    local sh = data.sh
    --[[
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
			p.position_y = p.planet_r
			p.motion_vy = -p.motion_vy
		end
		if p.position_y > sh then
			p.position_y = sh
			p.motion_vy = -p.motion_vy
		end
	end
	--]]
	 local sw = data.sw
    local sh = data.sh
	for _i,p in ipairs(g2.search("planet")) do
		if p.position_x-p.planet_r < 0 then
			p.position_x = p.planet_r
			--p.motion_vx = -p.motion_vx
		end
		if p.position_x+p.planet_r > sw then
			p.position_x = sw-p.planet_r
			--p.motion_vx = -p.motion_vx
		end
		if p.position_y-p.planet_r < 0 then
			p.position_y = p.planet_r
			--p.motion_vy = -p.motion_vy
		end
		if p.position_y+p.planet_r > sh then
			p.position_y = sh-p.planet_r
			--p.motion_vy = -p.motion_vy
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
			if(data.won == false) then
				data.won = true
				for j,planet in ipairs(g2.search("planet")) do
					planet.motion_vx = 0
					planet.motion_vy = 0
					planet:sync()
				end
				
				local users = g2.search("user")
				for j,user in pairs(users) do
					if(user ~= winner) then
						surrender(user.user_uid)
					end
				end
			end
			
			


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