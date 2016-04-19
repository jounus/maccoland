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
function init_koh()

local mode = {}
GAME.mode:addMode(mode,"koh")
mode.description = "Close your ring to win!"
mode.presets = {}
	
	

mode:addPreset("default","Nothing special.",
{
	neutrals = {24,24},
	hillcost = {0,25},
	hillprod = {150,150},
	hilltime = {30},
	inittime = {8},
	neutprod = {15,100},
	neutcost = {0,40},
	startships = {100},
	startprod = {100},
	width = {600},
	height = {400}
})


mode:addPreset("small","Nothing special.",
{
	neutrals = {24,24},
	hillcost = {0,25},
	hillprod = {150,150},
	hilltime = {30},
	inittime = {8},
	neutprod = {30,100},
	neutcost = {0,35},
	startships = {100},
	startprod = {100},
	width = {600},
	height = {400}
})

mode:addPreset("medium","Nothing special.",
{
	neutrals = {40,40},
	hillcost = {0,25},
	hillprod = {150,150},
	hilltime = {30},
	inittime = {8},
	neutprod = {50,100},
	neutcost = {0,35},
	startships = {100},
	startprod = {100},
	width = {800},
	height = {500}
})


mode:addPreset("large","Nothing special.",
{
	neutrals = {65,65},
	hillcost = {0,25},
	hillprod = {150,150},
	hilltime = {30},
	inittime = {8},
	neutprod = {50,100},
	neutcost = {0,40},
	startships = {100},
	startprod = {100},
	width = {900},
	height = {700}
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


if(settings["hillcost"][1] > settings["hillcost"][2]) then
	settings["hillcost"][1] = settings["hillcost"][2]
end

if(settings["hillprod"][1] > settings["hillprod"][2]) then
	settings["hillprod"][1] = settings["hillprod"][2]
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


---------------------------------------------------------------------------
--INIT FUNCTION, called when a game is started with /start
--Needs to be named and have the exact same signature as here
--You may use the field GAME.clients[user.user_uid].bonus if you want to give
--players that have bonus set some kinda advantage
---------------------------------------------------------------------------
mode.init = function(users,neutral)

local settings = mode.settings
local sw = settings["width"][1]
local sh = settings["height"][1]
    g2.view_set(0, 0, sw, sh)  -- set the size of the screen


--save any data needed for this mode
local data = {}
data.winTime = 5
data.winT = data.winTime
data.users = users
data.userData = {}
data.hillTime = mode.settings["hilltime"][1]
data.initTime = mode.settings["inittime"][1]
data.gameStopped = false


for i,user in pairs(data.users) do
	local userData = {}
	userData.points = 0
	userData.time = 0
	data.userData[user.user_uid] = userData

end

local hillProd = math.random(settings["hillprod"][1],settings["hillprod"][2])
local hillCost = math.random(settings["hillcost"][1],settings["hillcost"][2])
data.hillPlanet = g2.new_planet(neutral, sw/2, sh/2, hillProd, hillCost);



mode.data = data



	local numPlanets = math.random(settings["neutrals"][1],settings["neutrals"][2])

	
	

       local a = math.random(0,360)

    for i=1,numPlanets do
        local x,y
        x = sw/2 + (sw/1.3)*math.cos(a*math.pi/180.0)/2.0
        y = sh/2 + (sh/1.3)*math.sin(a*math.pi/180.0)/2.0
      	 local prod = math.random(settings["neutprod"][1],settings["neutprod"][2])
        local cost = math.random(settings["neutcost"][1],settings["neutcost"][2])
        g2.new_planet(neutral, x,y, prod, cost);
        a = a + 360/numPlanets
    end

    local a = math.random(0,360)
    
--add users home planets to the map
    for i,user in pairs(users) do
    	--local bonus = GAME.clients[user.user_uid].bonus
    	
        local x,y
        x = sw/2 + (sw/1.3)*math.cos(a*math.pi/180.0)/2.0
        y = sh/2 + (sh/1.3)*math.sin(a*math.pi/180.0)/2.0
        local startShips = settings["startships"][1]
        
        g2.new_planet(user, x,y, settings["startprod"][1], startShips);
        a = a + 360/#users
    end

    g2.planets_settle(0,0,sw,sh)	
    
    data.hillCircle = g2.new_circle(0xFFFFFF, data.hillPlanet.position_x, data.hillPlanet.position_y, data.hillPlanet.planet_r)


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
	
	
    	--data.hillCircle.position_x = data.hillPlanet.position_x
    	--data.hillCircle.position_y = data.hillPlanet.position_y
    	
        for i,user in pairs(data.users) do
        	local userData = data.userData[user.user_uid]
        	if(userData.points > data.hillTime) then
        		if(data.gameStopped == false) then
        			data.hillPlanet.ships_value = 100000
        			--userData.points = 0
        		end
        		for j,u in pairs(data.users) do
        			local uData = data.userData[user.user_uid]
        			if(u.user_uid ~= user.user_uid) then
        				if(data.gameStopped == false) then
        				
        					
        					surrender(u.user_uid)
        					
        				end
        			end
        		end
        		data.gameStopped = true
        	end
        	
        	if(data.hillPlanet.ships_value < -0.1) then
        		data.hillPlanet.ships_value = 0
        		data.hillPlanet:planet_chown(GAME.galcon.neutral)
        		data.hillCircle.draw_r = data.hillPlanet.planet_r
        		data.hillCircle.render_color = 0xFFFFFF
        	end
        	
        	
        	if(data.hillPlanet.owner_n == user.n) then
        			if(userData.time > data.initTime) then
        				userData.points = userData.points+t
        			end
        			userData.time = userData.time+t
        			data.hillCircle.render_color = user.render_color
        			local rad = data.hillPlanet.planet_r+(30-((userData.points/data.hillTime)*30))+3.5
        			if(rad < data.hillPlanet.planet_r) then
        				rad = data.hillPlanet.planet_r
        			end
        			if(math.abs(data.hillCircle.draw_r-rad) > 0.2) then
        				data.hillCircle.draw_r = rad
        			end
        		else
        			userData.time = 0
        		end
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
    	stopGame(nil)
    end
    
    
end
end