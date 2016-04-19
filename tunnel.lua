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


function init_tunnel()
---------------------------------------------------------------------------
--ADD THE MODE
---------------------------------------------------------------------------
local mode = {}
GAME.mode:addMode(mode,"tunnel")
mode.description = "Blame Saand."
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

mode.data = data



local settings = mode.settings
local sw = 750
local sh = 450

	local numPlanets = 70
   for i=1,numPlanets do
        local x = math.random(200,sw)
        local y = math.random(0,sh)
        local prod = math.random(40,125)
        local cost = math.random(0,15)
        g2.new_planet(neutral, x, y, prod, cost);
   end
   
    local a = math.random(0,360)
    
    local finalPlanet = g2.new_planet(neutral, sw-100, sh/2, 200, 0)
    data.finalPlanet = finalPlanet
  
    
    local numUsers = 0
    for i,user in pairs(users) do
    	numUsers = numUsers+1
    end
    local num = 1
    

--add users home planets to the map
    for i,user in pairs(users) do
    	user.fleet_v_factor = 1
        local x,y
        x = 40
        y = sh*(num/numUsers)-50
        num = num+1
        local startProduction = 100
        local startShips = 100
        g2.new_planet(user, x,y, startProduction, startShips);
        a = a + 360/#users
    end

    g2.planets_settle(0,0,sw,sh)	
     g2.planets_settle(0,0,sw,sh)	

    local r = finalPlanet.planet_r
   local size = (r*2)*0.7
	local black_hole = g2.new_image("icon-trophy", finalPlanet.position_x, finalPlanet.position_y, size, size)
	black_hole.image_cx = size/2
	black_hole.image_cy = size/2
    
    

end


---------------------------------------------------------------------------
--LOOP FUNCTION, called every frame during the game
--Needs to be named and have the exact same signature as here
---------------------------------------------------------------------------
mode.loop = function(t)
	
	--stopGame(nil)
	
	local data = mode.data
	if(data == nil) then
		stopGame(nil)
		return
	end
	--print(data.finalPlanet)
	
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