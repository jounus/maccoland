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

function init_football()
---------------------------------------------------------------------------
--ADD THE MODE
---------------------------------------------------------------------------
local mode = {}
GAME.mode:addMode(mode,"football")
mode.description = "Weeeeeeeeeeeee!"
mode.presets = {}
mode.maxTeams = 2

	

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
	
	local pData = {}
	mode.pData = pData
	pData.drawField = true
	pData.redGoals = 0
	pData.blueGoals = 0
	pData.redLabel = nil
	pData.blueLabel = nil
	initFootball(users,neutral)
end

function initFootball(users,neutral) 
--save any data needed for this mode
    local data = {}
    mode.data = data
    

    data.winTime = 7
    data.putBallBack = false
    data.winT = data.winTime
    data.users = {}
    data.syncT = 0
    data.won = false
    data.maxspeed = 1000
    data.rockets = {}
    data.userData = {}
    data.wallHits = 0
    data.winners = {}
    
    local settings = mode.settings
    
    --set field size depending on number of users
    local sw = 1000
    local sh = 600

    
    if(#users == 2) then
    	sw = 800
    	sh = 450
    elseif(#users == 3 or #users == 4) then
    	sw = 925
    	sh = 565
    elseif(#users == 5 or #users == 6) then
    	sw = 980
    	sh = 590
    elseif(#users >= 14) then
    	sw = 1100
    	sh = 650
    end
    data.sw = sw
    data.sh = sh
    
    
    
    
 

	--make users
	for i,user in pairs(users) do
		user:destroy()
	end

	--g2.state = "lobby"
	--g2.game_reset()
    --g2.state = "play"

	 local o = g2.new_user("neutral",0x555555)
    o.user_neutral = 1
    o.user_team_n = 1
    o.ships_production_enabled = 0
    GAME.galcon.neutral = o
    GAME.game.neutral = o

	users = {}
	local redTeam = {}
	local blueTeam = {}
	local redColors = {0xff4c4c,0xb20000,0xff0000,0xff7f7f,0xffb2b2,0x660000}
	local redColorInd = 1
	local blueColors = {0x5580f4,0x0000ff,0x7f7fff,0x4c4cff,0x000099,0xb2b2ff}
	local blueColorInd = 1

	local team = "red"
	
	local clients = GAME.clients
	shuffle(clients)
  	for uid,client in pairs(clients) do
        if client.status == "play" and (GAME.settings.approval == false or client.approved == true) then
        
        	local name = client.name
        	if(client.title == "") then
        		name = client.name
        	else
        		name = client.title
        	end
        	
        	if(GAME.settings.teams[client.name] == 1) then
        		team = "blue"
        	else
        		team = "red"
        	end
        	
        
        	local color = 0xFFFFFF
        	if(team == "red") then
        		color = redColors[redColorInd]
        		redColorInd = redColorInd+1
        		if(redColorInd > #redColors) then
        			redColorInd = 1
        		end
        	end
        	
        	if(team == "blue") then
        		color = blueColors[blueColorInd]
        		blueColorInd = blueColorInd+1
        		if(blueColorInd > #blueColors) then
        			blueColorInd = 1
        		end
        	end
          	local p = g2.new_user(nameStr(client),color)
		 	p.user_uid = client.uid
            users[#users+1] = p
            local userData = {}
            userData.team = team
            data.userData[p.n] = userData
            
            if(team == "red") then
            	redTeam[#redTeam+1] = p
            else
            	blueTeam[#blueTeam+1] = p
            end
            p.planet_style = json.encode({ 
    			texture="tex0",lighting=true,normal=true,  
       			overdraw = {texture="tex7", ambient=true,addition=false} 
   			 })
   			 
   			 if(client.headband > 0) then
           		p.planet_style = json.encode({ 
                texture="dec1",lighting=true,normal=true,  
                overdraw = {texture="dec1", ambient=false,addition=false} 
                })
            end
       
           	
           	if(client.lavaplanet > 0) then
				p.planet_style = json.encode({ 
                texture="tex5",lighting=false,normal=false,  
                overdraw = {texture="tex5", ambient=false,addition=false} 
                })
             
            end
            
            
            p.ui_to_mask = 0x3
			p.ships_production_enabled = false
			p.fleet_v_factor = 10
			p.user_reveal = true
          
        end
    end
	shuffle(users)
	data.users = users
     
	--make football
	neutral.planet_style = json.encode({ 
    	texture="tex5",lighting=true,normal=true,  
       	overdraw = {texture="tex5", ambient=false,addition=false} 
    })
    
	local football = g2.new_planet(neutral, sw/2, sh/2, 100, 0)
    football.title_value = "football"
    football.has_motion = true
    football.has_physics = true
    football.motion_vx = 0
    football.motion_vy = 0
    data.football = football	
    
	--make rockets  
   	    local spacingRed = data.sh/(#redTeam+1)
   	    local spacingBlue = data.sh/(#blueTeam+1)
      	local blueNum = 1
      	local redNum = 1
       for i,user in pairs(users) do
         	local x,y,x1,y1,x2,y2
         	if(data.userData[user.n].team == "red") then
         	    x = 150
        		y = redNum*spacingRed
        		x1 = x-30
        		y1 = y+10
        		x2 = x-30
        		y2 = y-10
        		redNum = redNum+1
         	elseif(data.userData[user.n].team == "blue") then
         	  	 x = data.sw-150
        		y = blueNum*spacingBlue
        		x1 = x+30
        		y1 = y+10
        		x2 = x+30
        		y2 = y-10
        		blueNum = blueNum+1
         	end
        	

        local p = g2.new_planet(user, x,y, 100, 90.5)
        local p1 = g2.new_planet(user, x1,y1, 50, 5)
        local p2 = g2.new_planet(user, x2,y2, 50, 5)
        p.ships_value = 90.999
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
         

    --Draw field
   -- if(mode.pData.drawField == true) then
   
    local bg = g2.new_image("background02", 0, 0, sw, sh)
    bg.render_alpha = 150
	--bg.image_cx = 25
	--bg.image_cy = 25
	bg.render_zindex = -1
	


	
	--local midBg = g2.new_image("blackhole",sw/2,sh/2,100,100)
	--midBg.image_cx = 25
--	midBg.image_cy = 25
	--midBg.render_zindex = -1
   
   	 local fieldColor = 0x555555
    g2.new_line(fieldColor,0,0,sw,0)
    g2.new_line(fieldColor,0,sh,sw,sh)
    
    local middleLine = g2.new_line(fieldColor,sw/2,0,sw/2,sh)
   	middleLine.render_zindex = -1
    
    local middleCircle = g2.new_circle(fieldColor,sw/2,sh/2,75)
   	middleCircle.render_zindex = -1
    
    local middlePoint = g2.new_circle(0x111111,sw/2,sh/2,1)
   	middlePoint.render_zindex = -1

    local redGoal = g2.new_line(0x8b0303,0,0,0,sh)
    redGoal.render_alpha = 10
    local blueGoal = g2.new_line(0x02149f,sw,0,sw,sh)
    
    
    mode.pData.redLabel = g2.new_label(tostring(mode.pData.redGoals),sw/2-50,sh+30,0xFF0000)
	mode.pData.redLabel.render_alpha = 125
	mode.pData.redLabel.label_font = "font"
	mode.pData.redLabel.label_size = 60
	
	mode.pData.blueLabel = g2.new_label(tostring(mode.pData.blueGoals),sw/2+50,sh+30,0x0000FF)
	mode.pData.blueLabel.render_alpha = 125
	mode.pData.blueLabel.label_font = "font"
	mode.pData.blueLabel.label_size = 60
    mode.pData.drawField = false
    

    
    
	--end
	
	
    
    g2.view_set(0, 0, sw, sh)
    g2.bounds_set(0, 0, sw, sh)


end

function updateScoreDisplay() 
	mode.pData.redLabel.label_text = tostring(mode.pData.redGoals)
	mode.pData.blueLabel.label_text = tostring(mode.pData.blueGoals)
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
			local ballSpeed = math.sqrt(data.football.motion_vx*data.football.motion_vx+data.football.motion_vy*data.football.motion_vy)
			local planetSpeed = math.sqrt(planet.motion_vx*planet.motion_vx+planet.motion_vy*planet.motion_vy)
			--print(planetSpeed)
			--print(planet.ships_production)
			--[[
			if(planet.ships_production == 100) then
				if(planetSpeed > 40) then
					data.football.motion_vx = data.football.motion_vx+planet.motion_vx*0.1
					data.football.motion_vy = data.football.motion_vy+planet.motion_vy*0.1
				end
			end
			--]]
			
			if(planetSpeed > 28) then
				net_send("","sound","sfx-hit")
			end
		end
	end
	
	data.wallHits = data.wallHits*0.996
	if(data.wallHits > 10) then
		print(data.wallHits)
	end
	
	for i,planet in pairs(planets) do
		if(planet.position_y-planet.planet_r <= 2) then
			planet.motion_vy = planet.motion_vy+35
			if(planet == data.football) then
				data.wallHits = data.wallHits+0.7
				planet.motion_vy = planet.motion_vy+1*data.wallHits
			end
		end
		if(planet.position_y+planet.planet_r >= data.sh-2) then
			planet.motion_vy = planet.motion_vy-35
			if(planet == data.football) then
				data.wallHits = data.wallHits+0.7
				planet.motion_vy = planet.motion_vy-1*data.wallHits
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
	
	--if(data.won == false) then

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
				thrust1AcelX = thrust1AcelX*(rocket.thruster1.ships_value/59)
				thrust1AcelY = thrust1AcelY*(rocket.thruster1.ships_value/59)
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
				thrust2AcelX = thrust2AcelX*(rocket.thruster2.ships_value/59)
				thrust2AcelY = thrust2AcelY*(rocket.thruster2.ships_value/59)
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
	
	
	--end
		
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
    			if(user ~= nil) then
    				if(data.userData[user.n] ~= nil) then
    				if(data.userData[user.n].team == "red") then
    					surrender(user.user_uid)
    				elseif(data.userData[user.n].team == "blue") then
    					data.winners[#data.winners+1] = user
    				end
    			end
    			end
    		end
    		data.won = true
			net_send("","message","Team BLUE wins!")
			net_send("","sound","sfx-dropin")
			mode.pData.blueGoals = mode.pData.blueGoals+1
			updateScoreDisplay() 
		end
	elseif(data.football.position_x+data.football.planet_r > data.sw-0.01) then
		if(data.won == false) then
			for i,user in pairs(data.users) do
				if(user ~= nil) then
					if(data.userData[user.n] ~= nil) then
    				if(data.userData[user.n].team == "blue") then
    					surrender(user.user_uid)
    				elseif(data.userData[user.n].team == "red") then
    					data.winners[#data.winners+1] = user
    				end
    			end
    			end
    		end
    		
			data.won = true
			net_send("","message","Team RED wins!")
			net_send("","sound","sfx-dropin")
			mode.pData.redGoals = mode.pData.redGoals+1
			updateScoreDisplay() 

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
        	--data.putBallBack = true
        	stopGame2(data.winners)
        	--data.winT = 1000000000
        	--data.winTime = 1000000000
        	
        	
		end
    end
  
    
    if(data.putBallBack == true) then
		local acelX = (data.sw/2)-data.football.position_x
		local acelY = (data.sh/2)-data.football.position_y
		local dist = math.sqrt(acelX*acelX+acelY+acelY)
		if(dist > 1) then
			acelX = acelX/dist
			acelY = acelY/dist	
		end
		
		data.football.motion_vx = data.football.motion_vx+acelX*3
		data.football.motion_vy = data.football.motion_vy+acelY*3
		data.football.motion_vx = data.football.motion_vx*0.98
		data.football.motion_vy = data.football.motion_vy*0.98
		if(dist < 2.5) then
			
			data.football.motion_vx = 0
			data.football.motion_vy = 0
			data.putBallBack = false
			for i,planet in pairs(g2.search("planet")) do
        		planet:destroy()
        	end
        	--data.football:destroy()
        	--stopGame(nil)
        	
        	initFootball(data.users,GAME.game.neutral)
        	
        --	return
		end
	
	
		
	
		
	end
   
    
    if(#data.users == 0) then
    	stopGame(nil)
    end
    
    
    
    
end

end