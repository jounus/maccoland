---------------------------------------------------------------------------
--STANDARD MODE
--Made By: Macco
---------------------------------------------------------------------------

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



---------------------------------------------------------------------------
--ADD THE MODE
---------------------------------------------------------------------------
function init_elim()

local mode = {}
GAME.mode:addMode(mode,"elim")
mode.description = "1v1 til ur handsz fall off!"
mode.presets = {}
	
	

mode:addPreset("default","Nothing special.",
{
	neutrals = {27,27},
	neutprod = {15,100},
	neutcost = {0,40},
	startships = {100},
	startprod = {100},
	width = {600},
	height = {400}
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
elseif(settings["width"][1] < 50) then
	settings["width"][1] = 50
end

if(settings["height"][1] > 5000) then
	settings["height"][1] = 5000
elseif(settings["height"][1] < 50) then
	settings["height"][1] = 50
end


end


function makeGame(left,right,top,bottom)

local game = {}
game.user1 = nil
game.user2 = nil
game.left = left
game.right = right
game.top = top
game.bottom = bottom
game.state = "wait"
game.changeUsers = true
game.winTime = 5
game.winT = game.winTime
mode.data.games[#mode.data.games+1] = game
game.countDownPlanet = nil
game.map = getRandomMap()
game.state = "wait"
game.countDown = 5

end

function getRandomMap()
	local index = math.random(1,#mode.data.maps-1)
	local map = mode.data.maps[index]
	return map
end

function makeUserData(user) 
	local uData = {}
	uData.live = 0
	uData.lastPlayedUid = 0
	uData.user = user
	uData.loseTime = 5
	uData.loseT = uData.loseTime
	uData.waitTime = 0
	uData.view = "big"
	mode.data.userData[user.user_uid] = uData	
end

---------------------------------------------------------------------------
--INIT FUNCTION, called when a game is started with /start
--Needs to be named and have the exact same signature as here
--You may use the field GAME.clients[user.user_uid].bonus if you want to give
--players that have bonus set some kinda advantage
---------------------------------------------------------------------------
mode.init = function(users,neutral)

local settings = mode.settings
local sw = 800
local sh = 800

--g2.view_set(0, -20, 600, 400+20)  -- set the size of the screen
--g2.view_set(0, -20, 1500, 1100+20)  -- set the size of the screen



--save any data needed for this mode
local data = {}
mode.data = data

data.winTime = 5
data.winT = data.winTime
data.users = {}
data.userData = {}
data.gameStopped = false


data.maps = {}
for i=0,1000 do
	data.maps[#data.maps+1] = generateMap()
end

data.games = {}
makeGame(0,600,0,400)
makeGame(900,1500,0,400)
makeGame(0,600,700,1100)
makeGame(900,1500,700,1100)




for i,game in pairs(data.games) do
	addHomes(game)
	resetGame(game)
end

for i,user in pairs(users) do
	user:destroy()
end


end

function addNeutrals(game)
	game.state = "play"
	for i,p in pairs(game.map.neutrals) do
		g2.new_planet(GAME.game.neutral, game.left+p.position_x,game.top+p.position_y, p.ships_production, p.ships_value);
	end

	game.user1Home.ships_production = 100
	game.user2Home.ships_production = 100
	game.user1Home.ships_value = 100
	game.user2Home.ships_value = 100
	syncPlanets()
end


function addHomes(game)
	local p = game.map.user1Home
	game.user1Home = g2.new_planet(GAME.game.neutral, game.left+p.position_x,game.top+p.position_y, p.ships_production, p.ships_value);
	
	p = game.map.user2Home
	game.user2Home = g2.new_planet(GAME.game.neutral, game.left+p.position_x,game.top+p.position_y, p.ships_production, p.ships_value);
	syncPlanets()
end

function syncPlanets()
	local planets = g2.search("planet")
	for i,planet in pairs(planets) do
   		planet:sync()
   	end
end

function generateMap() 
	local map = {}
	map.neutrals = {}
	map.user1Home = nil
	map.user2Home = nil
	--make neutrals
	local neutral = GAME.game.neutral
	local settings = mode.settings
	local sh = 400
	local sw = 600
	local numPlanets = 26
	
	local mapType = math.random(0,4)
	
	local user1Home = nil
	local user2Home = nil
	--mapType = 2
	if(mapType == 0) then
		 for i=1,numPlanets/2 do
       		 local x = sw/2 + math.random(-(sw)/2,(sw)/2)
       		 local y = sh/2 + math.random(-(sh)/2,(sh)/2)
       		 local prod = math.random(15,100)
       		 local cost = math.random(0,40)
       		 g2.new_planet(neutral, x, y, prod, cost);
       		 g2.new_planet(neutral, sw - x, sh - y, prod, cost);
   		end
   		
   		local homeFac = math.random(100,140)/100

     	local a = math.random(0,360)

		local x = sw/2 + (sw/homeFac)*math.cos(a*math.pi/180.0)/2.0
        local y = sh/2 + (sh/homeFac)*math.sin(a*math.pi/180.0)/2.0
        local startProduction = 100
        local startShips = 100
       	user1Home = g2.new_planet(neutral,x,y,startProduction,0)
        a = a + 360/2
        
        
        x = sw/2 + (sw/homeFac)*math.cos(a*math.pi/180.0)/2.0
        y = sh/2 + (sh/homeFac)*math.sin(a*math.pi/180.0)/2.0
        startProduction = 100
        startShips = 100
        user2Home = g2.new_planet(neutral,x,y,startProduction,0)
        a = a + 360/2
        
		g2.planets_settle()
	elseif(mapType == 1) then
	
		
		local spacing = 100
		local maxI = math.floor(sw/spacing)/2
		local maxJ = math.floor(sh/spacing)
		
		for i=0,maxI do
			for j=0,maxJ do
				local x = i*spacing
				local y = j*spacing
				local prod = math.random(15,100)
      	 		local cost = math.random(0,40)
      	 		local planet1 = g2.new_planet(neutral,x,y, prod, cost);
      	 		local planet2 = nil
      	 		if(i ~= 3) then
      	 			planet2 = g2.new_planet(neutral, sw - x, sh - y, prod, cost);
      	 		end

      	 		if(i == 0 and j == 0) then
					user1Home = planet1
					user2Home = planet2
				end
			end
		end
	
	elseif(mapType == 2) then
	

	 for i=1,7 do
       		 local x = sw/4 + math.random(-(sw)/4,(sw)/4)
       		 local y = sh/4 + math.random(-(sh)/4,(sh)/4)

       		 local prod = math.random(15,100)
       		 local cost = math.random(0,40)
       		 g2.new_planet(neutral, x, y, prod, cost);
       		 g2.new_planet(neutral, sw - x, sh - y, prod, cost);
       		 g2.new_planet(neutral, x, sh - y, prod, cost);
       		 g2.new_planet(neutral, sw - x, y, prod, cost);


       		-- g2.new_planet(neutral, x, y, prod, cost);
       		-- g2.new_planet(neutral, sw - x, sh - y, prod, cost);
   		end
   		
   		local homeFac = math.random(100,140)/100

     	local a = math.random(0,360)

		local x = sw/2 + (sw/homeFac)*math.cos(a*math.pi/180.0)/2.0
        local y = sh/2 + (sh/homeFac)*math.sin(a*math.pi/180.0)/2.0
        local startProduction = 100
        local startShips = 100
       	user1Home = g2.new_planet(neutral,x,y,startProduction,0)
        a = a + 360/2
        
        
        x = sw/2 + (sw/homeFac)*math.cos(a*math.pi/180.0)/2.0
        y = sh/2 + (sh/homeFac)*math.sin(a*math.pi/180.0)/2.0
        startProduction = 115
        startShips = 100
        user2Home = g2.new_planet(neutral,x,y,startProduction,0)
        a = a + 360/2
        
		--g2.planets_settle(0,0,sw,sh)
		g2.planets_settle()
	
	elseif(mapType == 3) then
		local a = math.random(0,math.pi*2)
	 	for i=1,14 do
       		 local x = sw/4 + math.random(-(sw)/4,(sw)/4)
       		 local y = sh/4 + math.random(-(sh)/4,(sh)/4)
       		 a = a+1
       		 x = sw/2+math.cos(a)*190
       		 y = sh/2+math.sin(a)*190

       		 local prod = math.random(15,100)
       		 local cost = math.random(0,40)
       		 g2.new_planet(neutral, x, y, prod, cost);
       		 g2.new_planet(neutral, sw - x, sh - y, prod, cost);
       	


       		-- g2.new_planet(neutral, x, y, prod, cost);
       		-- g2.new_planet(neutral, sw - x, sh - y, prod, cost);
   		end
   		
   		local homeFac = math.random(100,140)/100

     	local a = math.random(0,360)

		local x = sw/2 + (sw/homeFac)*math.cos(a*math.pi/180.0)/2.0
        local y = sh/2 + (sh/homeFac)*math.sin(a*math.pi/180.0)/2.0
        local startProduction = 100
        local startShips = 100
       	user1Home = g2.new_planet(neutral,x,y,startProduction,0)
        a = a + 360/2
        
        
        x = sw/2 + (sw/homeFac)*math.cos(a*math.pi/180.0)/2.0
        y = sh/2 + (sh/homeFac)*math.sin(a*math.pi/180.0)/2.0
        startProduction = 100
        startShips = 100
        user2Home = g2.new_planet(neutral,x,y,startProduction,0)
        a = a + 360/2
        
		--g2.planets_settle(0,0,sw,sh)
		g2.planets_settle()
	
	
	elseif(mapType == 4) then
		local lastX = sw/2
		local lastY = sh/2
		
		local randX = math.random(0,sw)
		local randY = math.random(0,sh)
		
	 	for i=1,30 do
	 		
       		 local x = sw/2 + math.random(-(sw)/2,(sw)/2)
       		 local y = sh/2 + math.random(-(sh)/2,(sh)/2)
       	

       		 local prod = math.random(15,100)
       		 local cost = math.random(0,40)
       		 g2.new_planet(neutral, x, y, prod, cost);
       		 g2.new_planet(neutral, sw - x, sh - y, prod, cost);

   		end
   		

   		for i=1,5 do
   			local x = sw/2
   			local y = i*20+75
   			--g2.new_planet(neutral, x, y, 15,30);
   			--g2.new_planet(neutral, sw - x, sh - y, 15, 30);
   		end

   		
   		local homeFac = math.random(100,140)/100

     	local a = math.random(0,360)

		local x = sw/2 + 250
        local y = sh/2
        local startProduction = 100
        local startShips = 100
       	user1Home = g2.new_planet(neutral,x,y,startProduction,0)
       	user2Home = g2.new_planet(neutral,sw-x,sh-y,startProduction,0)
        	g2.planets_settle()

        
		--g2.planets_settle(0,0,sw,sh)
	
	
	end
	
	--[[
	for i=1,10 do
		for j=1,5 do
			local x = i*25
			local y = j*25
			local prod = math.random(settings["neutprod"][1],settings["neutprod"][2])
      	 	local cost = math.random(settings["neutcost"][1],settings["neutcost"][2])
			g2.new_planet(neutral,x,y, 50, cost);
		end
	end
	
	--]]

  
   

   		
		--save and destroy planets
		local p = {}
		p.position_x = user1Home.position_x
	 	p.position_y = user1Home.position_y
		p.ships_value = user1Home.ships_value
		p.ships_production = user1Home.ships_production
		map.user1Home = p
		user1Home:destroy()
		
		local p = {}
		p.position_x = user2Home.position_x
	 	p.position_y = user2Home.position_y
		p.ships_value = user2Home.ships_value
		p.ships_production = user2Home.ships_production
		map.user2Home = p
		user2Home:destroy()
		
		local planets = g2.search("planet")
		for i,planet in pairs(planets) do
		   	local p = {}
		   	p.position_x = planet.position_x
		   	p.position_y = planet.position_y
			p.ships_value = planet.ships_value
			p.ships_production = planet.ships_production
			map.neutrals[#map.neutrals+1] = p
			planet:destroy()
		end
		
		
	
		
        return map
  	 -- end
   		 
end





function resetGame(game)
game.changeUsers = true
game.map = getRandomMap()
local sh = game.bottom-game.top
local sw = game.right-game.left
local settings = mode.settings

	

	local pad = 100
	
	for j=1,10 do
	local planets = g2.search("planet")
	for i,planet in pairs(planets) do
		--if(planet ~= game.user1Home and planet ~= game.user2Home) then
			if(planet.position_x > game.left-pad and planet.position_x < game.right+pad) then
				if(planet.position_y > game.top-pad and planet.position_y < game.bottom+pad) then
					planet:destroy()
				end
			end
		--end
	end
	end
	
	
	addHomes(game)
	
	game.countDown = 5
	game.state = "wait"
	game.user1Home.ships_production = 0
	game.user2Home.ships_production = 0
	game.user1Home.ships_value = 0
	game.user2Home.ships_value = 0
	syncPlanets()
	
end


function addUserToGame(user,game) 
	local uData = mode.data.userData[user.user_uid]
	
	if(game.user1 == nil) then
		uData.live = 1
		game.user1 = user
		game.user1Home:planet_chown(user)
		return true
	end
	
	if(game.user2 == nil) then
		uData.live = 1
		game.user2 = uData.user
		game.user2Home:planet_chown(uData.user)
		return true
	end
	
	--[[
	if(game.user1 ~= nil) then

	--print(uData.waitTime,mode.data.userData[game.user1.user_uid].waitTime)
		if(uData.waitTime > mode.data.userData[game.user1.user_uid].waitTime+1) then
			print(uData.waitTime)
			mode.data.userData[game.user1.user_uid].live = 0
			uData.live = 1
			game.user2 = uData.user
			game.user2Home:planet_chown(uData.user)
			return true
		end
	end
	
	
	if(game.user2 ~= nil) then
		if(uData.waitTime > mode.data.userData[game.user2.user_uid].waitTime+1) then
			print(uData.waitTime)
			mode.data.userData[game.user2.user_uid].live = 0
			uData.live = 1
			game.user2 = uData.user
			game.user2Home:planet_chown(uData.user)
			return true
		end
	end
	--]]
	
	
	return false
end
---------------------------------------------------------------------------
--Needs to be named and have the exact sam--LOOP FUNCTION, called every frame during the game
--same signature as here
---------------------------------------------------------------------------
mode.loop = function(t)
	
	local data = mode.data
	if(data == nil) then
		stopGame(nil)
		return
	end
	
	local userData = data.userData
	
	syncPlanets()

--[[
   local planets = g2.search("planet")
   for i,planet in pairs(planets) do
   	--planet.position_x = planet.position_x+math.random(-planet.ships_value/100-1,planet.ships_value/100+1)
   	--planet.position_y = planet.position_y+math.random(-planet.ships_value/100-1,planet.ships_value/100+1)
   if(planet:owner() ~= GAME.game.neutral) then
   		planet.ships_production = planet.ships_production-t*10
   	--	if(planet.ships_production < 10) then
  	 	--	planet.ships_production = 10
  	 --	end
  	 	planet.planet_r = planetRad(planet.ships_production)
  	 	if(planet.ships_value <= 0 and planet.ships_production < -100) then
  	 	--	planet:planet_chown(GAME.game.neutral)
  	 	end
  	 	
   end
   end
   --]]

 
	
	--make new user if it doesn't exists yet
	for uid,client in pairs(GAME.clients) do
        if client.status == "play" and (GAME.settings.approval == false or client.approved == true) then 	
        	if(userData[client.uid] == nil) then
				--local user = g2.new_user(client.name,client.color)
				local user = addUser(client)
				--user.user_uid = client.uid
				makeUserData(user)
        	end
        end
    end
    
    for i,client in pairs(GAME.clients) do
    	if client.status ~= "play" or (GAME.settings.approval == true and client.approved == false) then 	
			local p = {-50, -50, 1500+100, 1100+100}
			net_send(client.uid,"view",json.encode(p))
			net_send(client.uid,"clip",json.encode(p))
		end
    
    end
    
    -- delete users of clients that left
   	for j,ud in pairs(userData) do
   		local user = ud.user
		local found = false
   		 for i,client in pairs(GAME.clients) do
    		if(client.uid == user.user_uid) then
    			if client.status == "play" and (GAME.settings.approval == false or client.approved == true) then 	
    				found = true
    			end
    		end
    	end
    	if(found == false) then
     		for k,game in pairs(data.games) do
    			if(game.user1 == user) then
    				game.user1 = nil
    			end
    			if(game.user2 == user) then
    				game.user2 = nil
    			end
    		end
    		userData[user.user_uid] = nil
    		surrender(user.user_uid)
    		user:destroy()
    	end
    end
    
    
    -- update waiting time of users
    for i,ud in pairs(userData) do
    	
   		local user = ud.user
    	local uData = userData[user.user_uid]
    	if(uData ~= nil) then
    		uData.waitTime = uData.waitTime+t
    	end
    end
    
    
    -- add users to game
     for i,ud in pairs(userData) do
   		local user = ud.user	
		local uData = userData[user.user_uid]
		if(uData ~= nil) then
  			for i,game in pairs(data.games) do
  				if(game.state ~= "play") then
    				local foundHome = false
    				--if(foundHome == false and uData.live == 0) then
    				if(foundHome == false and uData.live == 0) then
    					foundHome = addUserToGame(user,game)
    				end
    			end
   			end 
   		end 
    end
    
    
    for i,ud in pairs(userData) do
   		local user = ud.user
   		ud.live = 0	
   	end
   
   
   local fleets = g2.search("fleet")	
   local padding = 200
   local fleetsToDestroy = {}
   	--kill cheating fleets
   for i,game in pairs(data.games) do
   		for j,fleet in pairs(fleets) do
   			if(fleet ~= nil) then
				if(fleet:owner() == game.user1 or fleet:owner() == game.user2) then
					if(fleet.position_x < game.left-50 or fleet.position_x > game.right+50 or fleet.position_y < game.top-50 or fleet.position_y > game.bottom+50) then
						fleetsToDestroy[fleet.n] = fleet
					end
				end
			end
		end  
   
   end
   
   for i,fleet in pairs(fleetsToDestroy) do
		fleet:destroy()
	end
   	
   	--if 2 people are waiting in different games, merge them
   	local waitingUser = nil
   for i,game in pairs(data.games) do   
   		if(game.state == "wait" and ((game.user1 == nil and game.user2 ~= nil) or (game.user2 == nil and game.user1 ~= nil))) then
   			if(waitingUser == nil) then
				if(game.user1 ~= nil) then
					waitingUser = game.user1
				end
				if(game.user2 ~= nil) then
					waitingUser = game.user2
				end
			else
				surrender(waitingUser.user_uid)
				if(game.user1 ~= nil) then
					surrender(game.user1.user_uid)
				end
				if(game.user2 ~= nil) then
					surrender(game.user2.user_uid)
				end
			end
   		end
   
   end

    
    for i,game in pairs(data.games) do   
    	
    	if(game.state == "countdown" or game.state == "wait") then
    		if(game.user1Home:owner() == GAME.game.neutral) then
    			game.user1 = nil
    		end
    		if(game.user2Home:owner() == GAME.game.neutral) then
    			game.user2 = nil
    		end
    	end
    	
    	
    		if(game.user1 ~= nil) then
    			userData[game.user1.user_uid].live = 1
    		end
    		if(game.user2 ~= nil) then
    			userData[game.user2.user_uid].live = 1
    		end
      end
    
    
     
    for i,game in pairs(data.games) do
    
    
    if(game.state == "wait") then
    if(game.user1 ~= nil) then
    	if (userData[game.user1.user_uid].view ~= "big") then
					userData[game.user1.user_uid].view = "big"
					local client = findClient(game.user1.user_uid)
					local p = {-50, -50, 1500+100, 1100+100}
					net_send(client.uid,"view",json.encode(p))
					net_send(client.uid,"clip",json.encode(p))

				end
	end
    if(game.user2 ~= nil) then
    	if (userData[game.user2.user_uid].view ~= "big") then
					userData[game.user2.user_uid].view = "big"
					local client = findClient(game.user2.user_uid)
					local p = {-50, -50, 1500+100, 1100+100}
					net_send(client.uid,"view",json.encode(p))
					net_send(client.uid,"clip",json.encode(p))

				end
	end
    
    end
    
    
  
    
    if(game.state == "countdown") then
  
    	
    	
    
    	if(game.user1 == nil or game.user2 == nil) then
    
    		game.state = "wait"
    		game.countDown = 5
    		if(game.countDownPlanet ~= nil) then
    			game.countDownPlanet:destroy()
    			game.countDownPlanet = nil
    		end
    	end
    	end
    	
		if(game.user1 ~= nil and game.user2 ~= nil) then
			--start countdown
			if(game.state == "wait") then
				game.state = "countdown"
				local countDownPlanet = g2.new_planet(GAME.game.neutral,(game.user1Home.position_x+game.user2Home.position_x)/2,(game.user1Home.position_y+game.user2Home.position_y)/2,150,game.countDown)
				game.countDownPlanet = countDownPlanet
				
				

			end
			
			--countdown
			if(game.state == "countdown") then
				if (userData[game.user1.user_uid].view ~= "small") then
					local client = findClient(game.user1.user_uid)
					local p = {game.left-30, game.top-30, 600+60, 400+60}
					net_send(client.uid,"view",json.encode(p))
					net_send(client.uid,"clip",json.encode(p))

					userData[game.user1.user_uid].view = "small"
					

				end
				if (userData[game.user2.user_uid].view ~= "small") then
					local client = findClient(game.user2.user_uid)
					local p = {game.left-30, game.top-30, 600+60, 400+60}

					net_send(client.uid,"view",json.encode(p))
					net_send(client.uid,"clip",json.encode(p))
				--	net_send(client.uid,"clip",json.encode(p))
					userData[game.user2.user_uid].view = "small"
				end
				game.countDown = game.countDown-t
				if(game.countDownPlanet.ships_value-game.countDown >= 0.2) then 
					game.countDownPlanet.ships_value = game.countDown+1
				end
				--start game
				if(game.countDown <= 0) then
					game.countDownPlanet:destroy()
					addNeutrals(game)
					game.state = "play"
				end
			end
		end
	end
	


	 for i,ud in pairs(userData) do
   		local user = ud.user
		if(userData[user.user_uid] ~= nil and userData[user.user_uid].live == 1) then
			userData[user.user_uid].loseT = userData[user.user_uid].loseT - t
		end
	end

	--calculate lose time
	local planets = g2.search("planet -neutral")
	for i,p in pairs(planets) do
        local owner = p:owner()
        if(userData[owner.user_uid] ~= nil) then
       		 userData[owner.user_uid].loseT = userData[owner.user_uid].loseTime
       	end
	end	
		
	--end game early (faster games yay!)	
	for i,game in pairs(data.games) do
		local user1 = game.user1
		local user2 = game.user2
		if(user1 ~= nil and user2 ~= nil) then
			local user1Ships = numShips(user1)
			local user2Ships = numShips(user2)
			local user1Prod = production(user1)
			local user2Prod = production(user2)
			--reset wintimer
			if(user1Ships+user1Prod > 0 and user2Ships+user2Prod > 0) then
				game.winT = game.winTime
			end
			
			if(user2Prod > 0) then
				if(user1Ships > 4*user2Ships and user1Prod > 2*user2Prod) then
					userData[user2.user_uid].loseT = 2
					surrender(user2.user_uid)
				end
			end
			
			if(user1Prod > 0) then
				if(user2Ships > 4*user1Ships and user2Prod > 2*user1Prod) then
					userData[user1.user_uid].loseT = 2
					surrender(user1.user_uid)
				end 
			end
		end
	end
	
	--rearrange players of games that are not in "play" state
	
	local tempGame = nil
	for i,game in pairs(data.games) do
		if(game.state == "wait") then
    		game.changeUsers = true
    	end
	
		if(game.state ~= "play" and game.changeUsers == true and (game.user1 ~= nil or game.user2 ~= nil)) then
			if(tempGame == nil) then
				tempGame = game
			else
				if(game.state == "countdown") then
					game.countDownPlanet:destroy()
					game.countDownPlanet = nil
					game.state = "wait"
				end
				if(tempGame.state == "countdown") then
					tempGame.countDownPlanet:destroy()
					tempGame.countDownPlanet = nil
					tempGame.state = "wait"
				end
				tempGame.changeUsers = false
				game.changeUsers = false
				tempGame.countDown = 7
				game.countDown = 7
				
				local rand = math.random(0,2)
				
				if(rand == 0) then
					local tempUser = game.user1
					game.user1 = tempGame.user1
					tempGame.user1 = tempUser
					
					if(game.user1 ~= nil) then
						game.user1Home:planet_chown(game.user1)
					else
						game.user1Home:planet_chown(GAME.game.neutral)
					end
					if(tempGame.user1 ~= nil) then
						tempGame.user1Home:planet_chown(tempGame.user1)
					else
						tempGame.user1Home:planet_chown(GAME.game.neutral)
					end
				elseif(rand == 1) then
					local tempUser = game.user2
					game.user2 = tempGame.user2
					tempGame.user2 = tempUser
					
					if(game.user2 ~= nil) then
						game.user2Home:planet_chown(game.user2)
					else
						game.user2Home:planet_chown(GAME.game.neutral)
					end
					if(tempGame.user2 ~= nil) then
						tempGame.user2Home:planet_chown(tempGame.user2)
					else
						tempGame.user2Home:planet_chown(GAME.game.neutral)
					end
				elseif(rand == 2) then
					local tempUser = game.user2
					game.user2 = tempGame.user1
					tempGame.user1 = tempUser
					
					if(game.user2 ~= nil) then
						game.user2Home:planet_chown(game.user2)
					else
						game.user2Home:planet_chown(GAME.game.neutral)
					end
					if(tempGame.user1 ~= nil) then
						tempGame.user1Home:planet_chown(tempGame.user1)
					else
						tempGame.user1Home:planet_chown(GAME.game.neutral)
					end
				end
				
			end
			
		end
	end

	
	
	
	
	--surrender when lose time is up
	 for i,ud in pairs(userData) do
   			local user = ud.user
				if(userData[user.user_uid].loseT <= 0) then
					userData[user.user_uid].loseT = userData[user.user_uid].loseTime
					surrender(user.user_uid)				
				end
	end
	
	
	--end the game
				for i,game in pairs(data.games) do
					if(game.state == "play") then
					game.winT = game.winT-t
					
					
					if(game.winT < 0) then
						game.winT = game.winTime
						
						
						if(game.user1 ~= nil and game.user2 ~= nil) then
							
							local user1Prod = production(game.user1)
							local user2Prod = production(game.user2)
							
							if(user1Prod > user2Prod) then
								net_send("","message",game.user1.title_value.." ELIMINATED "..game.user2.title_value.."!")
							elseif(user2Prod > user1Prod) then
								net_send("","message",game.user2.title_value.." ELIMINATED "..game.user1.title_value.."!")
							end
							
							surrender(game.user1.user_uid)
							surrender(game.user2.user_uid)
							userData[game.user2.user_uid].live = 0
							userData[game.user1.user_uid].live = 0
							userData[game.user1.user_uid].waitTime = math.random(0,15)
							userData[game.user2.user_uid].waitTime = math.random(0,15)
							game.user1 = nil
							game.user2 = nil
							resetGame(game)						

						else
							if(game.user1 ~= nil) then
								surrender(game.user1.user_uid)
								userData[game.user1.user_uid].live = 0
								userData[game.user1.user_uid].waitTime = math.random(0,15)
								net_send("","message",game.user1.title_value.." ELIMINATED ".."lame quitter".."!")

							end
							if(game.user2 ~= nil) then
								surrender(game.user2.user_uid)
								userData[game.user2.user_uid].live = 0
								userData[game.user2.user_uid].waitTime = math.random(0,15)
								net_send("","message",game.user2.title_value.." ELIMINATED ".."lame quitter".."!")

							end
							game.user1 = nil
							game.user2 = nil
							resetGame(game)	
						end
						
						for i,game in pairs(data.games) do   
   							if(game.state == "wait" and ((game.user1 == nil and game.user2 ~= nil) or (game.user2 == nil and game.user1 ~= nil))) then
   								if(game.user1 ~= nil) then
   									surrender(game.user1.user_uid)
   								end
   								if(game.user2 ~= nil) then
   									surrender(game.user2.user_uid)
   								end
   							end
   						end

						--userData[game.user1.user_uid].waitTime = 0
					--	userData[game.user2.user_uid].waitTime = 0
						--userData[game.user1.user_uid].live = 0
					--	userData[game.user2.user_uid].live = 0
					end
				end
			end
				
				
	--[[
		local planets = g2.search("planet -neutral")
		local users = g2.search("user -neutral")
		for i,user in pairs(users) do
						--print(user)
			print("hi")
			print(user.user_uid)
			print("hi2")
			--print(userData[user.user_uid])
			userData[user.user_uid].loseT = userData[user.user_uid].loseT - t
			if(userData[user.user_uid].loseT <= 0) then
				userData[user.user_uid].loseT = userData[owner.user_uid].loseTime
				surrender(user.user_uid)
				for i,game in pairs(data.games) do
					if(game.user1 == user) then
						game.user1 = nil
					end
					if(game.user2 == user) then
						game.user2 = nil
					end
				end
			end
		end
		
		
		for i,p in pairs(planets) do
        	local owner = p:owner()
        	userData[owner.user_uid].loseT = userData[owner.user_uid].loseTime
		end
		--]]
		
    --[[
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
    --]]
    
    
end
end
