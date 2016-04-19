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

function init_rocket()
---------------------------------------------------------------------------
--ADD THE MODE
---------------------------------------------------------------------------
local mode = {}
GAME.mode:addMode(mode,"rocket")
mode.description = "Fly your rocket! "
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

    mode.data = data
    
  

    local settings = mode.settings
    local sw = 1000
    local sh = 600
    if(#users >= 9) then
    	sw = 1100
    	sh = 650
    end
    data.sw = sw
    data.sh = sh
    data.syncT = 0
    data.won = false
    data.maxspeed = 1000
    data.rockets = {}
    data.userData = {}
    
	neutral.planet_style = json.encode({ 
                texture="tex5",lighting=true,normal=true,  
                overdraw = {texture="tex5", ambient=false,addition=false} 
                })
	
for i,user in pairs(users) do
	user:destroy()
end


users = {}
local redTeam = {}
local blueTeam = {}

local team = 0xFF0000
  for uid,client in pairs(GAME.clients) do
        if client.status == "play" and (GAME.settings.approval == false or client.approved == true) then
        	local name = client.name
        	if(client.title == "") then
        		name = client.name
        	else
        		name = client.title
        	end
        	if(team == 0xFF0000) then
        		team = 0x0000FF
        	elseif(team == 0x0000FF) then
        		team = 0xFF0000
        	end
          	local p = g2.new_user(nameStr(client),team)
		 	p.user_uid = client.uid
            users[#users+1] = p
            
            if(team == 0xFF0000) then
            	redTeam[#redTeam+1] = p
            else
            	blueTeam[#blueTeam+1] = p
            end
            
            
            p.ui_to_mask = 0x3
			p.ships_production_enabled = false
			p.fleet_v_factor = 10
			p.user_reveal = true
          
        end
    end
	shuffle(users)

      
		 	local x = sw/2
 
            local y = sh/2
            local prod = math.random(15,100)
            local cost = math.random(0,50)
            local p = g2.new_planet(neutral, x, y, 100, 0)
            data.football = p
            data.football.title_value = "football"
            p.has_motion = true
            p.has_physics = true
            p.motion_vx = 0
            p.motion_vy = 0
            
            
        local spacing = data.sh/(#redTeam+1)
       for i,user in pairs(redTeam) do
         	local x,y,x1,y1,x2,y2
         	x = 150
        	y = i*spacing
        	x1 = x-30
        	y1 = y+10
        	x2 = x-30
        	y2 = y-10
        	
        	 local startProduction = 100
        local startShips = 100
        local p = g2.new_planet(user, x,y, 100, 90)
        local p1 = g2.new_planet(user, x1,y1, 50, 6)
        local p2 = g2.new_planet(user, x2,y2, 50, 6)
        local rocket = {}
        rocket.head = p
        rocket.thruster1 = p1
        rocket.thruster2 = p2
        data.rockets[#data.rockets+1] = rocket
        
        p.has_motion = true
        p.has_physics = true
        p1.has_motion = true
        p1.has_physics = true
        p2.has_motion = true
        p2.has_physics = true
      end
      
      
      	spacing = data.sh/(#blueTeam+1)
       for i,user in pairs(blueTeam) do
         	local x,y,x1,y1,x2,y2
         	x = data.sw-150
        	y = i*spacing
        	x1 = x+30
        	y1 = y+10
        	x2 = x+30
        	y2 = y-10
        	
        	 local startProduction = 100
        local startShips = 100
        local p = g2.new_planet(user, x,y, 100, 90)
        local p1 = g2.new_planet(user, x1,y1, 50, 6)
        local p2 = g2.new_planet(user, x2,y2, 50, 6)
        local rocket = {}
        rocket.head = p
        rocket.thruster1 = p1
        rocket.thruster2 = p2
        data.rockets[#data.rockets+1] = rocket
        
        p.has_motion = true
        p.has_physics = true
        p1.has_motion = true
        p1.has_physics = true
        p2.has_motion = true
        p2.has_physics = true
      end
         
--[[
  
    local a = math.random(0,360)
    --add users home planets to the map
    for i,user in pairs(users) do
        local x,y,x1,y1,x2,y2
        
        
      --  if(user.render_color == 0xFF0000) then
        --	x = 100
        --	y = #
        --end
        
        x = sw/2 + (sw/2)*math.cos(a*math.pi/180.0)/2.0
        y = sh/2 + (sh/2)*math.sin(a*math.pi/180.0)/2.0
        x1 = sw/2 + (sw/2)*math.cos(a*math.pi/180.0)/2.0+math.cos(a*math.pi/180.0)*30+10
        y1 = sh/2 + (sh/2)*math.sin(a*math.pi/180.0)/2.0+math.sin(a*math.pi/180.0)*30
        x2 = sw/2 + (sw/2)*math.cos(a*math.pi/180.0)/2.0+math.cos(a*math.pi/180.0)*30
        y2 = sh/2 + (sh/2)*math.sin(a*math.pi/180.0)/2.0+math.sin(a*math.pi/180.0)*30
        
		
        local startProduction = 100
        local startShips = 100
        local p = g2.new_planet(user, x,y, 100, 90)
        local p1 = g2.new_planet(user, x1,y1, 50, 6)
        local p2 = g2.new_planet(user, x2,y2, 50, 6)
        local rocket = {}
        rocket.head = p
        rocket.thruster1 = p1
        rocket.thruster2 = p2
        data.rockets[#data.rockets+1] = rocket
        
        p.has_motion = true
        p.has_physics = true
        p1.has_motion = true
        p1.has_physics = true
        p2.has_motion = true
        p2.has_physics = true
	 --   p.motion_vx = data.maxspeed*(2*math.random() - 1)*math.cos(p.position_x*p.position_y)
       -- p.motion_vy = data.maxspeed*(2*math.random() - 1)*math.sin(p.position_x*p.position_y)
        a = a + 360/#users
    end
    --]]
    
    
    
    local raceTrackColor = 0x555555
   -- g2.new_line(raceTrackColor,0,0,0,sh)
    --g2.new_line(raceTrackColor,sw,0,sw,sh)
    g2.new_line(raceTrackColor,0,0,sw,0)
    g2.new_line(raceTrackColor,0,sh,sw,sh)
    
    
    local line = g2.new_line(raceTrackColor,sw/2,0,sw/2,sh)
    line.render_zindex = -1
    
    local circle = g2.new_circle(raceTrackColor,sw/2,sh/2,75)
    circle.render_zindex = -1
    
    circle = g2.new_circle(0x111111,sw/2,sh/2,1)
   circle.render_zindex = -1


    
    g2.new_line(0xFF0000,0,0,0,sh)
    g2.new_line(0x0000FF,sw,0,sw,sh)

    
    g2.view_set(0, 0, sw, sh)
    g2.bounds_set(0, 0, sw, sh)
    --g2.planets_settle(0, 0, sw, sh)	
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
	
	
	local planets = g2.search("planet")
	for i,planet in pairs(planets) do
		if(planet:owner() == GAME.game.neutral) then
			if(planet ~= data.football) then
				for i,rocket in pairs(data.rockets) do
					if(rocket.head == planet) then
						data.rockets[i] = nil
					end
				end
				planet:destroy()
			end
		end
	end
	
	

	
	
	planets = g2.search("planet")
	for i,planet in pairs(planets) do
		if(planet:distance(data.football) < data.football.planet_r+planet.planet_r and planet ~= data.football) then
			local speed = math.sqrt(data.football.motion_vx*data.football.motion_vx+data.football.motion_vy*data.football.motion_vy)
			if(speed > 20) then
				net_send("","sound","sfx-hit")
			end
		end
	end
	
	
	local hasPlanets = false
	for i,planet in pairs(planets) do
		if(planet ~= data.football) then
			hasPlanets = true
		end
	end
	
	if(hasPlanets == false) then
		stopGame(nil)
	end


	data.football.motion_vx = data.football.motion_vx*0.9988
	data.football.motion_vy = data.football.motion_vy*0.9988
	
	for i,rocket in pairs(data.rockets) do
		--if(rocket.thruster1:distance(rocket.head) > rocket.thruster1.planet_r+rocket.head.planet_r+1) then
			
			local dir = 1
			if(rocket.head.ships_value >= 99) then
				dir = -1
			end
			local backSpeed = 1.5
			
			local thrust1AcelX = (rocket.head.position_x-rocket.thruster1.position_x)
			local thrust1AcelY = (rocket.head.position_y-rocket.thruster1.position_y)
			local length = math.sqrt(thrust1AcelX*thrust1AcelX+thrust1AcelY*thrust1AcelY)
			if(length ~= 0) then
				thrust1AcelX = thrust1AcelX/length
				thrust1AcelY = thrust1AcelY/length
			end
			
			local dist = rocket.thruster1:distance(rocket.head)-(rocket.thruster1.planet_r+rocket.head.planet_r)
			if(dist > 5) then
				rocket.thruster1.motion_vx = rocket.thruster1.motion_vx+(thrust1AcelX)*3
				rocket.thruster1.motion_vy = rocket.thruster1.motion_vy+(thrust1AcelY)*3
			elseif(dist < 3) then
				rocket.thruster1.motion_vx = rocket.thruster1.motion_vx-(thrust1AcelX)*3
				rocket.thruster1.motion_vy = rocket.thruster1.motion_vy-(thrust1AcelY)*3
			end

			if(dir == 1) then
				thrust1AcelX = thrust1AcelX*(rocket.thruster1.ships_value/60)
				thrust1AcelY = thrust1AcelY*(rocket.thruster1.ships_value/60)
			else
				thrust1AcelX = thrust1AcelX*backSpeed
				thrust1AcelY = thrust1AcelY*backSpeed
			end
			
			rocket.thruster1.motion_vx = rocket.thruster1.motion_vx+thrust1AcelX*dir
			rocket.thruster1.motion_vy = rocket.thruster1.motion_vy+thrust1AcelY*dir
			rocket.head.motion_vx = rocket.head.motion_vx+thrust1AcelX*dir
			rocket.head.motion_vy = rocket.head.motion_vy+thrust1AcelY*dir
			
			
			
			local thrust2AcelX = (rocket.head.position_x-rocket.thruster2.position_x)
			local thrust2AcelY = (rocket.head.position_y-rocket.thruster2.position_y)
			local length2 = math.sqrt(thrust2AcelX*thrust2AcelX+thrust2AcelY*thrust2AcelY)
			if(length2 ~= 0) then
				thrust2AcelX = thrust2AcelX/length2
				thrust2AcelY = thrust2AcelY/length2
			end
			
			local dist = rocket.thruster2:distance(rocket.head)-(rocket.thruster2.planet_r+rocket.head.planet_r)
			if(dist > 5) then
				rocket.thruster2.motion_vx = rocket.thruster2.motion_vx+(thrust2AcelX)*3
				rocket.thruster2.motion_vy = rocket.thruster2.motion_vy+(thrust2AcelY)*3
			elseif(dist < 3) then
				rocket.thruster2.motion_vx = rocket.thruster2.motion_vx-(thrust2AcelX)*3
				rocket.thruster2.motion_vy = rocket.thruster2.motion_vy-(thrust2AcelY)*3
			end

			if(dir == 1) then
				thrust2AcelX = thrust2AcelX*(rocket.thruster2.ships_value/60)
				thrust2AcelY = thrust2AcelY*(rocket.thruster2.ships_value/60)
			else
				thrust2AcelX = thrust2AcelX*backSpeed
				thrust2AcelY = thrust2AcelY*backSpeed
			end
			
			rocket.thruster2.motion_vx = rocket.thruster2.motion_vx+thrust2AcelX*dir
			rocket.thruster2.motion_vy = rocket.thruster2.motion_vy+thrust2AcelY*dir
			rocket.head.motion_vx = rocket.head.motion_vx+thrust2AcelX*dir
			rocket.head.motion_vy = rocket.head.motion_vy+thrust2AcelY*dir
			
			local acelX = rocket.thruster2.position_x-rocket.thruster1.position_x
			local acelY = rocket.thruster2.position_y-rocket.thruster1.position_y
			if(rocket.thruster1:distance(rocket.thruster2) < 40) then
			--	rocket.thruster1.motion_vx = rocket.thruster1.motion_vx-acelX*0.01
			--	rocket.thruster1.motion_vy = rocket.thruster1.motion_vy-acelY*0.01
			--	rocket.thruster2.motion_vy = rocket.thruster2.motion_vx+acelX*0.01
			--	rocket.thruster2.motion_vy = rocket.thruster2.motion_vy+acelY*0.01
			end
			
			
			--local thrust2AcelX = (rocket.head.position_x-rocket.thruster2.position_x)*0.0001*rocket.thruster2.ships_value
			--local thrust2AcelY = (rocket.head.position_y-rocket.thruster2.position_y)*0.0001*rocket.thruster2.ships_value
			--rocket.thruster2.motion_vx = rocket.thruster2.motion_vx+thrust2AcelX
			--rocket.thruster2.motion_vy = rocket.thruster2.motion_vy+thrust2AcelY
			--rocket.head.motion_vx = rocket.head.motion_vx+thrust2AcelX
			--rocket.head.motion_vy = rocket.head.motion_vy+thrust2AcelY
		--end
		
		--if(rocket.thruster2:distance(rocket.head) > rocket.thruster2.planet_r+rocket.head.planet_r+1) then
		--	rocket.thruster2.motion_vx = rocket.thruster2.motion_vx+(rocket.head.position_x-rocket.thruster2.position_x)*0.1*rocket.thruster2.ships_value
		--	rocket.thruster2.motion_vy = rocket.thruster2.motion_vy+(rocket.head.position_y-rocket.thruster2.position_y)*0.1*rocket.thruster2.ships_value
		--end
		local damp = 0.97
		if(dir == -1) then
			damp = 0.99
		else
			damp = 0.97
		end
		rocket.thruster1.motion_vx = rocket.thruster1.motion_vx*damp
		rocket.thruster1.motion_vy = rocket.thruster1.motion_vy*damp
		rocket.thruster2.motion_vx = rocket.thruster2.motion_vx*damp
		rocket.thruster2.motion_vy = rocket.thruster2.motion_vy*damp
		rocket.head.motion_vx = rocket.head.motion_vx*damp
		rocket.head.motion_vy = rocket.head.motion_vy*damp
		
	
	
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
	
	local max_speed = data.maxspeed
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
	
	if(data.syncT > 0.05) then
		data.syncT = 0
		for i,p in ipairs(g2.search("planet")) do
			p:sync()
		end
	end
    --
    
    if(data.football.position_x-data.football.planet_r < 0.01) then
    	if(data.won == false) then
    		for i,user in pairs(data.users) do
    			if(user.render_color == 0xFF0000) then
    				surrender(user.user_uid)
    			end
    		end
    		data.won = true
			net_send("","message","Team BLUE wins!")
			net_send("","sound","sfx-dropin")
		end
	elseif(data.football.position_x+data.football.planet_r > data.sw-0.01) then
		if(data.won == false) then
			for i,user in pairs(data.users) do
    			if(user.render_color == 0x0000FF) then
    				surrender(user.user_uid)
    			end
    		end
			data.won = true
			net_send("","message","Team RED wins!")
			net_send("","sound","sfx-dropin")

		end
	end
	
    
    -- TEMPORARY: make sure all planets are inside map boundary
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
	
	

     if(data.won == false) then data.winT = data.winTime end
    
    if (data.won == true) then
       	data.winT = data.winT - t
        if (data.winT < 0) then
        	stopGame(nil)
		end
    end
   
    
    if(#data.users == 0) then
    	stopGame(nil)
    end
    
end

end