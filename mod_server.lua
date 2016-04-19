LICENSE = [[
mod_server.lua

Copyright (c) 2013 Phil Hassey
Modifed by: YOUR_NAME_HERE

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

Galcon is a registered trademark of Phil Hassey
For more information see http://www.galcon.com/
]]
--------------------------------------------------------------------------------
strict(true)
if g2.headless == nil then
    require("mod_client") -- HACK: not a clean import, but it works
end


require("html")
require("chatbot")
require("landmine")
require("commands")
require("utility")
require("config")
require("elim")
require("ffa")
require("koh")
require("angrykid")
require("cell")
require("billiards")
require("coop")
require("race")
require("infect")
require("killer")
require("gravity")
require("football")
require("shop")
require("tunnel")
require("lazor")



--------------------------------------------------------------------------------
function menu_init()
    GAME.modules.menu = GAME.modules.menu or {}
    local obj = GAME.modules.menu
    function obj:init()
        g2.state = "menu"
        
         g2.net_host(GAME.config.port)
         GAME.engine:next(GAME.modules.lobby)

         if g2.headless == nil then
         	g2.net_join("",GAME.config.port)
         end
    end
    function obj:loop(t) end
    function obj:event(e) end
end
--------------------------------------------------------------------------------

function clients_init()
    GAME.modules.clients = GAME.modules.clients or {}
    GAME.clients = GAME.clients or {}
    local obj = GAME.modules.clients
    function obj:event(e)
	
        if e.type == 'net:join' then
        	if(GAME.settings.hidden == false or e.uid == g2.uid) then
            	clientJoin(e)
            else
            	net_send("","message","Sorry "..e.name..", the server is hidden. You are not allowed to join.")
            end
        end
        if e.type == 'net:leave' then
        	if(GAME.clients[e.uid] ~= nil) then --for kicked players
            	clientLeave(e)
            end
        end
        
       	if e.type == 'net:message' and e.value ~= nil and e.value ~= "" then
       		
       	
       		if(GAME.clients[e.uid] ~= nil) then --for kicked players
       		GAME.clients[e.uid].afkTime = 0
       		if(GAME.clients[e.uid].status == "afk") then
       			GAME.clients[e.uid].status = "away"
       			clients_queue()

       		end
        	GAME.commands:check(e)
        	
        	local words = {}
          	local s = e.value
			for word in s:gmatch("%S+") do table.insert(words, word) end
			if(#words == 0) then return end
			

          	
          	for i,w in pairs(words) do
          		if(GAME.modules.chat.censored[w:lower()] ~= nil) then
        			words[i] = GAME.modules.chat.censored[w:lower()]
          		end
          	end


   				local str = ""
   				for i,var in pairs(words) do
   					if(var ~= nil) then
   						str = str..var.." "
   					end
   				end
   					
   				
   				
   				if(GAME.clients[e.uid].leet > 0) then
   					str = string.gsub(str, "a", "4")
   					str = string.gsub(str, "b", "8")
   					str = string.gsub(str, "e", "3")
   					str = string.gsub(str, "g", "6")
   					str = string.gsub(str, "i", "1")
   					str = string.gsub(str, "o", "0")
   					str = string.gsub(str, "s", "5")
   					str = string.gsub(str, "z", "2")
   					str = string.gsub(str, "t", "7")
   					
   			


   				end
   				
   				
   			
   				
   				if(GAME.clients[e.uid].swag > 0) then
   					str = string.gsub(str, "a", "å")
   					str = string.gsub(str, "i", "¡")
   					str = string.gsub(str, "o", "ø")
   					str = string.gsub(str, "r", "®")
   					str = string.gsub(str, "e", "ê")


   				end
   				
   				

   				
   				
        	local json = json.encode({uid=e.uid,color=GAME.clients[e.uid].color,value="<"..nameStr(GAME.clients[e.uid]).."> "..str})
        	
        	if(e.value ~= "") then
        	
        	
        	
        		if(GAME.clients[e.uid].muted <= 0) then

        		GAME.modules.chat.history[#GAME.modules.chat.history+1] = json
        		net_send("","chat",json)
        		
        		if(GAME.config.enableChatbot == true) then
        			botResponse(GAME.clients[e.uid],e.value)
        		end
        		
        		else
        			net_send(e.uid,"message","You are muted for " ..math.floor(GAME.clients[e.uid].muted).. " seconds.")
        		end
        	end
        	
        	
        	
        	end
        end
        
    end
end
--------------------------------------------------------------------------------
function params_set(k,v)
    GAME.params[k] = v
    net_send("",k,v)
end

function params_init()
    GAME.modules.params = GAME.modules.params or {}
    GAME.params = GAME.params or {}
    GAME.params.state = GAME.params.state or "lobby"
    GAME.params.html = GAME.params.html or ""
    local obj = GAME.modules.params
    function obj:event(e)
        if e.type == 'net:join' then
            net_send(e.uid,"state",GAME.params.state)
            net_send(e.uid,"html",GAME.params.html)
            net_send(e.uid,"tabs",GAME.params.tabs)
        end
    end
end
--------------------------------------------------------------------------------
function chat_init()
    GAME.modules.chat = GAME.modules.chat or {}
    GAME.modules.chat.history =  GAME.modules.chat.history or {} 
    GAME.modules.chat.censored = GAME.modules.chat.censored or {}

    GAME.clients = GAME.clients or {}
    local obj = GAME.modules.chat

    function obj:event(e) end
end
--------------------------------------------------------------------------------
function lobby_init()
    GAME.modules.lobby = GAME.modules.lobby or {}
    local obj = GAME.modules.lobby
    function obj:init()
       	g2.state = "lobby"
        params_set("state","lobby")
        params_set("tabs","<table class='box' width=160><tr><td><h2>"..GAME.config.roomName.."</h2></table>")
        params_set("html","<p>Lobby ... enter /start to play!</p>")
    end
    function obj:loop(t) end
    function obj:event(e) 
    	--if(e.type == "net:message" or e.type == "net:join" or e.type == "net:leave") then
    		--updateHtml()
    		if(g2.state == "lobby") then
    		if(e.uid ~= nil) then
    			local client = GAME.clients[e.uid]
    			if(client ~= nil) then
    				HTML(client)
    			end
    		end
    		end
    	--end
    end
end

function addUser(client)
	local p = g2.new_user(nameStr(client),client.color)
		 p.user_uid = client.uid
            p.user_reveal = GAME.settings.reveal
           	p.fleet_v_factor = GAME.settings.shipSpeed
           	
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
            


           	p.fleet_image = client.shipsTex
            
            if(GAME.settings.crash == true) then
            	p.fleet_crash = 100
            end

	return p;
end

--------------------------------------------------------------------------------
function galcon_classic_init()
	bot_reset()
   --Use time as a seed if seed is set to random. (0)
    local gameSeed
    if(GAME.settings.seed == 0) then
        gameSeed = os.time()
    else
    	gameSeed = GAME.settings.seed
    end
    GAME.game.time = 0
    math.randomseed(gameSeed)
	local test = math.random(0,1)
    g2.game_reset();
    
    local o = g2.new_user("neutral",0x555555)
    o.user_neutral = 1
    o.user_team_n = 1
    o.ships_production_enabled = 0
    GAME.galcon.neutral = o
    GAME.game.neutral = o
    
    
	local clients = {}
	for i,client in pairs(GAME.clients) do
		clients[#clients+1] = client
	end
	shuffle(clients)
    local users = {}
    for uid,client in pairs(clients) do
    
    	client.kohPoints = 0
    	client.kohTime = 0
        if client.status == "play" and (GAME.settings.approval == false or client.approved == true) then
        	local name = client.name
        	if(client.title == "") then
        		name = client.name
        	else
        		name = client.title
        	end
            local p = addUser(client)
            users[#users+1] = p
           
           	

        end
    end
    
	--makeMap(users,o,OPTS.gameMode)

    net_send("","message","Mode: "..GAME.mode.current.. ", Seed: " .. gameSeed)

    g2.net_send("","sound","sfx-start");
    
	GAME.mode.modeList[GAME.mode.current].limitValues()
	GAME.mode.modeList[GAME.mode.current].init(users,o)

end




function galcon_classic_loop(t)
	   --update game time
    GAME.game.time = GAME.game.time+t

    GAME.mode.modeList[GAME.mode.current].loop(t)
	
	--set clients that are playing as active
	local users = g2.search("user")
	for j,u in ipairs(users) do
		if(GAME.clients[u.user_uid] ~= nil) then
     		GAME.clients[u.user_uid].afkTime = 0
     	end
     end
     
    
    
   if(GAME.settings.refill == true) then
   		local mostShipsUser = find("user",
        		function(p) 
        			if(p == GAME.game.neutral) then
        				return -1000000
        			end
        			return numShips(p)
        		end)
        
        local mostShips = numShips(mostShipsUser)

   		for i,u in pairs(users) do 
   			if(u ~= GAME.game.neutral) then
   			local userShips = numShips(u)
   			
   			local numPlanets = 0
   			for n,e in pairs(g2.search("planet owner:"..u)) do
					numPlanets = numPlanets+1
			end
			
			
			if(mostShips/1.5 > userShips) then
				local amount = (mostShips-userShips)*0.3
				
				
				
				local num = amount/numPlanets
				
				for n,e in pairs(g2.search("planet owner:"..u)) do
       						local newShips = e.ships_value+num
							if(newShips < 0) then
								newShips = 0
							end
       						e.ships_value = newShips
   				end

			end
			end
   		end
   end
   
   

   
  --[[
   local planets = g2.search("planet")
   for i,planet in pairs(planets) do
   	--planet.position_x = planet.position_x+math.random(-planet.ships_value/100-1,planet.ships_value/100+1)
   	--planet.position_y = planet.position_y+math.random(-planet.ships_value/100-1,planet.ships_value/100+1)
   if(planet:owner() ~= GAME.game.neutral) then
   		planet.ships_production = GAME.planet_data[planet.n].origProd+(planet.ships_value/5)
  	 	planet.planet_r = planetRad(planet.ships_production)
   end
   
   
   
  -- g2.planets_settle(0,0,GAME.game.sw,GAME.game.sh)
   		if(planet.ships_value > 40) then
   			--local totShips = planet.ships_value
   			--planet.ships_value = totShips/2
   			--g2.new_planet(planet:owner(), planet.position_x,planet.position_y,planet.planet_r, totShips/2)
   			--g2.planets_settle(0,0,GAME.game.sw,GAME.game.sh)
   		end
   		if(planet.ships_value < 100) then
   		--	planet:destroy()
   			--g2.planets_settle(0,0,GAME.game.sw,GAME.game.sh)
   		end
   end
   
   local fleets = g2.search("fleet")
   for i,fleet in pairs(fleets) do
   		if(fleet.fleet_ships > 100) then
   			--g2.new_planet(fleet:owner(), fleet.position_x,fleet.position_y,fleet.fleet_ships, fleet.fleet_ships*0.5)
   			--fleet:destroy()
   			--g2.planets_settle(0,0,GAME.game.sw,GAME.game.sh)
   		end
   end
   
   for i,planet in pairs(planets) do
   	planet:sync()
   	end
   	--]]
  
   		

    
    
    GAME.game.botT = GAME.game.botT + t
    if (GAME.game.botT >= GAME.game.botWait) then
        GAME.game.botT = GAME.game.botT - GAME.game.botWait
        local users = g2.search("user")
        for _i,user in ipairs(users) do
			local c = GAME.clients[user.user_uid]
			if(c ~= nil) then
				if(c.bot ~= "") then
						if(c.bot == "bot") then
							bot_angrykid(user)
						elseif(c.bot == "melt") then
							bot_melt(user)
						elseif(c.bot == "sparky") then
							bot_sparky(user)
						end
					end
				end
				
			end
	end


     
  
end


function galcon_init()
    GAME.modules.galcon = GAME.modules.galcon or {}
    GAME.galcon = GAME.galcon or {}
    local obj = GAME.modules.galcon
    function obj:init()
        g2.state = "play"
        params_set("state","play")
        params_set("html",[[<table>
            <tr><td><input type='button' value='Resume' onclick='resume' />
            <tr><td><input type='button' value='Surrender' onclick='/surrender' />

            </table>]])
        galcon_classic_init()
    end
    function obj:loop(t)
        galcon_classic_loop(t)
    end
    function obj:event(e)
    	 if e.type == 'net:message' and e.value == 's' then
            surrender(e.uid)
        end
    
    end
end
--------------------------------------------------------------------------------
function register_init()
    GAME.modules.register = GAME.modules.register or {}
    local obj = GAME.modules.register
    obj.t = 0
    function obj:loop(t)
        if GAME.module == GAME.modules.menu then return end
        self.t = self.t - t
        if self.t < 0 then
            self.t = 60
            	if(GAME.settings.hidden == false) then
            		g2_api_call("register",json.encode({title=GAME.config.roomName.." ("..numClients()..")",port=GAME.config.port}))
            	end
        end
    end
end
--------------------------------------------------------------------------------
function engine_init()
    GAME.engine = GAME.engine or {}
    GAME.modules = GAME.modules or {}
    local obj = GAME.engine

    function obj:next(module)
        GAME.module = module
        GAME.module:init()
    end
    
    function obj:init()
        if g2.headless then
            GAME.data = { port = g2.port }
            g2.net_host(GAME.data.port)
            GAME.engine:next(GAME.modules.lobby)
        else
            self:next(GAME.modules.menu)
        end
    end
    
    function obj:event(e)
        GAME.modules.clients:event(e)
        GAME.modules.params:event(e)
        GAME.modules.chat:event(e)
        GAME.module:event(e)
        if e.type == 'onclick' then 
            GAME.modules.client:event(e)
        end
    end
    
    function obj:loop(t)
    	chatLoop(t)
    	botLoop(t)
        GAME.module:loop(t)
        GAME.modules.register:loop(t)
    end
end


function vote_init()
	GAME.vote = GAME.vote or {}
	GAME.vote.active = false
	GAME.vote.timer = 0
	GAME.vote.clientName = ""

end

function chatbot_init()
	GAME.chatbot = 
	{
	state = "default",
	angryLevel = 0,
	randLevel = 200,
	attentionLevel = 0,
	guessNumber = -1,
	miniGameTime = 0,
	}

end


function mode_init()
	local init = true
	if(GAME.mode == nil) then
		init = true
		GAME.mode =
		{current = "ffa",
		modeList = {},
		}
		
	else
		init = false
		GAME.mode = GAME.mode
	end
	
	function GAME.mode:addMode(mode,name)
		mode.currentPreset = "default"
		GAME.mode.modeList[name] = mode
		function mode:addPreset(name,description,settings)
			local preset = {}
			preset.name = name
			preset.description = description
			preset.settings = settings
			mode.presets[name] = preset
		end
	end
	
	--if(init == true) then
			init_ffa()
			init_koh()
			init_elim()
			init_billiards()
			init_cell()
			init_coop()
			init_race()
			init_infect()
			init_killer()
			init_gravity()
			init_football()
			init_landmine()
			init_zap()
			init_tunnel()
			init_lazor()
	
	if(#GAME.config.availableModes ~= 0) then
		for i,m in pairs(GAME.mode.modeList) do
			local keepMode = false
			for j,a in pairs(GAME.config.availableModes) do
            	if(i == a) then
            		keepMode = true
            	end
            end
            if(keepMode == false) then
            	GAME.mode.modeList[i] = nil
            end
        end
        
        for i,m in pairs(GAME.mode.modeList) do
        	GAME.mode.current = i
        end

		
	end
	
	local maxTeams = GAME.mode.modeList[GAME.mode.current].maxTeams

	if(maxTeams ~= nil) then
     	GAME.settings.numteams = maxTeams
     else
       GAME.settings.numteams = 0
     end

	--end
	
	
end

function colors_init()
	GAME.colors = GAME.colors or {}
	GAME.colors.colorList = {}
	local obj = GAME.colors
	
	function obj:addColor(value,name)
		local color = {}
		color.value = value
		color.name = name
		GAME.colors.colorList[#GAME.colors.colorList+1] = color
	end
	
	function obj:makeColors()
		self:addColor(0xff0000,"red")
		self:addColor(0x00ff00,"green")
		self:addColor(0x0000ff,"blue")
		self:addColor(0x8000ff,"purple")
		self:addColor(0xff00ff,"pink")
		self:addColor(0xff8000,"orange")
		self:addColor(0xffff00,"yellow")
		self:addColor(0x00ffff,"cyan")
		self:addColor(0xffffff,"white")
		self:addColor(0xfa8072,"salmon")
		self:addColor(0xCCCCFF,"periwinkle")
		self:addColor(0xccffcc,"mint")
		

		self:addColor(0xff4c4c,"red")
		self:addColor(0xb20000,"red")
		
		self:addColor(0x7fff7f,"green")
		self:addColor(0x009900,"green")
		
		self:addColor(0x000099,"blue")
		self:addColor(0x9999ff,"blue")
		
		self:addColor(0xbf7fff,"purple")
		self:addColor(0x4c0099,"purple")
		
		self:addColor(0x990099,"pink")
		self:addColor(0xff7fff,"pink")
		
		self:addColor(0x999900,"yellow")
		self:addColor(0xffffcc,"yellow")
		
		self:addColor(0x007f7f,"cyan")
		self:addColor(0xb2ffff,"cyan")
		
		self:addColor(0x7a3e37,"salmon")
		self:addColor(0xff8000,"orange")

		--self:addColor(0xdbffdb,"mint")
		self:addColor(0x0aa979,"mint")
		
		self:addColor(0xff69b4,"realpink")

	end
	
	obj:makeColors()

	
end

function settings_init()
	GAME.settings = GAME.settings or {
		strict = false,
		approval = false,
		numteams = 0,
		teamsedit = false,
		teams = {},
		autocensor = false,
		words = {},
		seed = 0,
		shipSpeed = 1,
		reveal = false,
		hidden = GAME.config.hideOnStart,
		refill = false,
		crash = false,
		wordData = {},
		clientorder = {},
		topic = GAME.config.topic,
		crazy = 0,
	}
	for i=1,100 do GAME.settings.clientorder[i]=i end
end

function store_init()
	if(GAME.store == nil) then
		GAME.store = {}
		GAME.store.items = {}
		
		local item = {}
		item.cost = 100
		item.name = "winMessage"
		GAME.store.items["winMessage"] = item

		
	end
end

function game_init()
	GAME.game = GAME.game or {
		time = 0,
		neutral = nil,
		botT = 0,
		botWait = GAME.config.botWait,
		hostSet = false,
		tipsTime = 0,
		won = {},
		tempSave = {clients={},}
	}
end


function bot_init()
	GAME.bot = GAME.bot or {bots = {},reload = {}}
	GAME.bot.reload = {}
end

function bot_reset()
	GAME.bot = {bots = {},reload = {}}
end





--------------------------------------------------------------------------------
function mod_init()
	global("GAME")
    GAME = GAME or {}
    bot_init()
    config_init()
    settings_init()
    game_init()
    store_init()
    chatbot_init()
    colors_init()
    vote_init()
    mode_init()
    commands_init()
    engine_init()
    menu_init()
    clients_init()
    params_init()
    chat_init()
    lobby_init()
    galcon_init()
    register_init()
    if g2.headless == nil then
        client_init()
    end
    --print("INITIALIZED")

end
--------------------------------------------------------------------------------
function init() GAME.engine:init() end
function loop(t) GAME.engine:loop(t) end
function event(e) GAME.engine:event(e) end
--------------------------------------------------------------------------------
function net_send(uid,mtype,mvalue) -- HACK - to make headed clients work
    if g2.headless == nil and (uid == "" or uid == g2.uid) then
        GAME.modules.client:event({type="net:"..mtype,value=mvalue})
    end
    g2.net_send(uid,mtype,mvalue)
end
--------------------------------------------------------------------------------
mod_init()

