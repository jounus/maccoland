function production(u)
        local planets = g2.search("planet owner:"..u)
        local production = 0
		for i,planet in pairs(planets) do
			production = production+planet.planet_r
		end
		return production
end


function numShips(u)
        		return numShipsInPlanets(u)+numShipsInFleets(u)
        	end
        	
        	function numShipsInPlanets(u)
        		local planets = g2.search("planet owner:"..u)
        		local ships = 0
				for i,planet in pairs(planets) do
					ships = ships+planet.ships_value
				end
				return ships
        	end
      
        	function numShipsInFleets(u)
        		local fleets = g2.search("fleet owner:"..u)
        		local ships = 0
				for i,fleet in pairs(fleets) do
					ships = ships+fleet.fleet_ships
				end
				return ships
        	end



function planetRad(production) 
local rad = math.max((3/17)*(production-15)+15,15)
if(rad > 100) then
	local over = math.log(rad-100)
	rad = 100+over
end

return rad

end



function shuffle(t)
	--math.randomseed(os.time())
    local rand = math.random 
    local iterations = #t
    local j
    
    for i = iterations, 2, -1 do
        j = rand(i)
        t[i], t[j] = t[j], t[i]
    end
end



function shallowCopy(t)
  local t2 = {}
  for k,v in pairs(t) do
    t2[k] = v
  end
  return t2
end

function clients_queue()

	--[[
    local colors = {
        0x0000ff,0xff0000,
        0xffff00,0x00ffff,
        0xffffff,0xff8800,
        0x99ff99,0xff9999,
        0xbb00ff,0xff88ff,
        0x9999ff,0x00ff00,
    }
    --]]
    local colors = shallowCopy(GAME.colors.colorList)
    local q = nil
    for k,e in pairs(GAME.clients) do
        if (e.status == "away" or e.status == "queue" or (GAME.settings.approval == true and e.approved == false)) then
            e.color = GAME.config.awayColor
        end
        if e.status == "queue" then q = e end
        for i,v in pairs(colors) do
            if v.value == e.color then 
            	colors[i] = nil 
            end
        end
    end
    
    
    if q ~= nil then
    
    if(GAME.settings.approval == true and q.approved == false) then
    	--return
    end

	local colorFound = false

    --preferred color?
    for i,v in pairs(colors) do
    	if(colorFound == false) then
        if v ~= nil then
        	if(v.name == q.preferredColor) then
        		q.color = v.value
           		q.status = "play"
            	net_send("","message",nameStr(q) .. " is /play")
            	colorFound = true
            end
        end
        end
	end
	
	--any color?
	for i,v in pairs(colors) do
		if(colorFound == false) then
        if v ~= nil then
        	q.color = v.value
            q.status = "play"
            net_send("","message",nameStr(q) .. " is /play")
            colorFound = true
        end
        end
	end
	end
	if(GAME.settings.numteams > 0 and GAME.settings.teamsedit == false) then
		randomizeTeams()
	end
	


end


function randomizeTeams()
	local clients = {}
	for i,client in pairs(GAME.clients) do
		clients[#clients+1] = client
	end
	shuffle(clients)
	
	local teamnum = 1
	for i,client in pairs(clients) do
		if(client.status == "play" and(GAME.settings.approval == false or client.approved == true)) then
			GAME.settings.teams[client.name] = teamnum
			teamnum = teamnum+1
			if(teamnum > GAME.settings.numteams) then
				teamnum = 1
			end
		end
	end
end



function clientWithName(name)
name = tostring(name)
if(name == nil) then return nil end
	for k,client in pairs(GAME.clients) do
           if(client.name:lower() == name:lower()) then
           		return client
           end
    end
	return nil
end

function setSavedClientAdminLevel(uid,adminLevel)
	
	if(uid ~= nil) then
		if(GAME.data.clients[uid] ~= nil) then
			GAME.data.clients[uid][1] = adminLevel
		end
	end
	saveData()

end

function surrender(uid)
    local user = findUser(uid)

    if user == nil then return end

    for n,e in pairs(g2.search("planet owner:"..user)) do
        e:planet_chown(GAME.galcon.neutral)
    end
    
    for n,e in pairs(g2.search("fleet owner:"..user)) do
        e:destroy() 
    end
end

function findUser(uid)
    for n,e in pairs(g2.search("user")) do
        if e.user_uid == uid then return e end
    end
end

function findClient(uid)
    for n,e in pairs(GAME.clients) do
        if e.uid == uid then return e end
    end
end


function nameStr(client)
	local name = client.name
	if(client.title ~= "") then
		name = client.title
	end
	if(client.adminLevel == 1) then
		name = "+"..name
	elseif(client.adminLevel == 2) then
		name = "@"..name
	elseif(client.adminLevel >= 3) then
		name = "#"..name
	end
	return name
end



function darkenColor(_color)
	return _color*0.9999
end

function stopGame(winner)
		GAME.game.won = {}
		saveData()
        if(winner ~= nil) then
       		local client = GAME.clients[winner.user_uid]
       		if(client ~= nil) then
       			
       			GAME.game.won[client.name] = true
       			local str = client.winMessage.." ("..math.floor(GAME.game.time).."sec)"
       		
   				local json2 = json.encode({uid=client.uid,color=0xAAAAAA,value="<== "..nameStr(client).." ==> "..str})
   				net_send("","chat",json2)
   			
        	end
        	local client = GAME.clients[winner.user_uid]
        	if(client ~= nil) then
        		client.wins = client.wins+1
        		if(client.bot ~= "") then
        			--local msg = "I win, noobs!"
        			--net_send("","chat",json.encode({uid=client.uid,color=client.color,value="<"..nameStr(client).."> "..msg}))
        		end
        	end
        end
    
   	net_send("","sound","sfx-stop");
    GAME.engine:next(GAME.modules.lobby)
    
    randomizeTeams()
    updateHtml()
end

--stopGame needs to be removed and only this function used
function stopGame2(winners)
		GAME.game.won = {}
		saveData()
        if(winners ~= nil) then
        	for i,user in pairs(winners) do
       			local client = GAME.clients[user.user_uid]
       		if(client ~= nil) then
       			
       			GAME.game.won[client.name] = true
       			local str = client.winMessage.." ("..math.floor(GAME.game.time).."sec)"
       		
   				local json2 = json.encode({uid=client.uid,color=0xAAAAAA,value="<== "..nameStr(client).." ==> "..str})
   				net_send("","chat",json2)
   			
        	if(client ~= nil) then
        		client.wins = client.wins+1
        		if(client.bot ~= "") then
        			--local msg = "I win, noobs!"
        			--net_send("","chat",json.encode({uid=client.uid,color=client.color,value="<"..nameStr(client).."> "..msg}))
        		end
        	end
        end
        end
     end
    
   	net_send("","sound","sfx-stop");
    GAME.engine:next(GAME.modules.lobby)
    
    randomizeTeams()
    updateHtml()
end


function updateHtml() 
	for i,client in pairs(GAME.clients) do
		if(client.bot == "") then
			HTML(client)
		end
	end
end



function numClients()
	local numClients = 0
    for i,cl in pairs(GAME.clients) do
    	if(cl.bot == "") then
       		numClients = numClients+1	
        end
    end
    
    return numClients
end

function clientJoin(e) 
		GAME.data = json.decode(g2.data)
		if(GAME.data == nil) then
			GAME.data = {}
		end
		if(GAME.data.clients == nil) then
			GAME.data.clients = {}
		end		

        local tempClient = {
            uid=tostring(e.uid), --important!
            name=e.name,
            title="",
            lastLogoutTime = 0,
            status="queue",
            vote="",
           	adminLevel = 0,
            color = GAME.config.awayColor,
            voteCoolDown = 0,
            approved = false,
            afkTime = 0,
            muted = 0,
            maccoins = 0,
            bot = "",
            wins = 0,
            winMessage = e.name.." CONQUERED the galaxy!",
            winMessageTime = 0,
            swag = 0,
            leet = 0,
            lavaplanet = 0,
            shipsTime = 0,
            shipsTex = "ship-0",
            headband = 0,
            preferredColor = "",
            lastLogoutTime = 0,
            window = "",
            timeInServer = 0,
            statusTxt = "",
            goat = false,
         }
        
			
         local savedClient = GAME.data.clients[e.uid]
         if(savedClient ~= nil) then
         	--tempClient.status = savedClient.status
            
            
            tempClient.adminLevel = savedClient[1]
            if(os.time()-savedClient[4] > 60*15) then
            	if(tempClient.adminLevel <= 2) then
            		tempClient.adminLevel = 0
            	end
           	end
            tempClient.maccoins = savedClient[2]
            tempClient.preferredColor = savedClient[3]
         else
         	net_send("","message","Please welcome "..tempClient.name.." to the server. First time here!")
         end
         
         local tempSave = GAME.game.tempSave.clients[e.uid]
         
         if(tempSave ~= nil) then
       	 		tempClient.approved = tempSave.approved
       	 		tempClient.muted = tempSave.muted
       	 		tempClient.wins = tempSave.wins
       	 		tempClient.swag = tempSave.swag
       	 		tempClient.leet = tempSave.leet
       	 		tempClient.title = tempSave.title
       	 		tempClient.timeInServer = tempSave.timeInServer
       	 		tempClient.statusTxt = tempSave.statusTxt or ""
       	 		tempClient.winMessage = tempSave.winMessage
       	 		tempClient.goat = tempSave.goat
       	 end

         
         local hasSuper = false
        local hasAdmin = false
      	local hasPlus = false

         for i,cl in pairs(GAME.clients) do
			if(cl.adminLevel >= 3 and cl.status ~= "afk") then
				hasSuper = true
			end
			if(cl.adminLevel == 2 and cl.status ~= "afk") then
				hasAdmin = true
			end
			if(cl.adminLevel == 1 and cl.status ~= "afk") then
				hasPlus = true
			end
		end
		
		if(tempClient.adminLevel <= 2) then
			if(hasSuper) then
				tempClient.adminLevel = 0
			end
			if(hasAdmin) then
				tempClient.adminLevel = 0
			end
			if(tempClient.adminLevel == 1) then
				if(hasPlus) then
					tempClient.adminLevel = 0
				end
			end
		end
		

         
         	
       	GAME.clients[e.uid] = tempClient
        	
        	
        if(GAME.settings.teams[tempClient.name] == nil) then
        	GAME.settings.teams[tempClient.name] = 1
        end
        
        	
        	--Make host higher than #super
    
        	if(g2.uid == tempClient.uid) then
        		GAME.clients[e.uid].adminLevel = 101        			
        	end
        	
        	
        	local startInd = #GAME.modules.chat.history-100
        	if(startInd < 1) then
        		startInd = 1
        	end
        	
        	for i=startInd,#GAME.modules.chat.history do
        		local msg = GAME.modules.chat.history[i]
        		net_send(e.uid,"chat",msg)
        	end
         	
            net_send("","message",nameStr(GAME.clients[e.uid]) .. " joined")
            for i,msg in pairs(GAME.config.welcomeMsgs) do
           		net_send(e.uid,"message",msg)
    		end

    		
            net_send("","sound","sfx-join");
            updateKeywords()
            
            params_set("state",g2.state)
            clients_queue()


end

function clientLeave(e)
	surrender(e.uid)
	GAME.clients[e.uid].lastLogoutTime = os.time()
	GAME.game.tempSave.clients[e.uid] = GAME.clients[e.uid]
	saveData()
    net_send("","message",nameStr(GAME.clients[e.uid]) .. " left")
    GAME.clients[e.uid] = nil
    net_send("","sound","sfx-leave");
    updateKeywords()
    clients_queue()
end


function updateKeywords() 
	local keywords = {}
	local num = 0
	for k,client in pairs(GAME.clients) do
		num = num+1
		keywords[num] = client.name
	end
	g2.chat_keywords( json.encode(keywords) )
	net_send("","keywords",json.encode(keywords))
end


function saveData()
	for k,client in pairs(GAME.clients) do
		
		if(client.bot == "") then -- dont save bots
			local save = {client.adminLevel,client.maccoins,client.preferredColor,client.lastLogoutTime}
      		GAME.data.clients[client.uid] = save
      		
      	end
	end
	
	g2.data = json.encode(GAME.data)
	
end



function chatLoop(t)
	for i,cl in pairs(GAME.clients) do
			if(cl.status ~= "afk") then
				cl.maccoins = cl.maccoins+(t/10)
			end
			if(cl.swag > 0) then
				cl.swag = cl.swag-t
			end
			if(cl.leet > 0) then
				cl.leet = cl.leet-t
			end
			
			if(cl.muted > 0) then
				cl.muted = cl.muted-t
			end
			
			cl.timeInServer = cl.timeInServer+t
		
			
			if(cl.lavaplanet > 0) then
				cl.lavaplanet = cl.lavaplanet-t
			end
			
			if(cl.headband > 0) then
				cl.headband = cl.headband-t
			end
			
			if(cl.winMessageTime > 0) then
				if(cl.winMessageTime-t <= 0) then
					cl.winMessage = cl.name.." CONQUERED the galaxy!"
				end
				cl.winMessageTime = cl.winMessageTime-t
			end
			
			if(GAME.settings.crazy > 0) then
				GAME.settings.crazy = GAME.settings.crazy-t
				

   				local json2 = json.encode({uid=nil,color=math.random(0,0xFFFFFF),value="PARTY".."->".."Cheers!"})
   				net_send("","chat",json2)
  			
			end
			
			if(cl.shipsTime > 0) then
				if(cl.shipsTime-t <= 0) then
					cl.shipsTex = "ship-0"
				end
				cl.shipsTime = cl.shipsTime-t
			end
			
			if(g2.state == "lobby") then
			GAME.game.tipsTime = GAME.game.tipsTime+t
			if(GAME.game.tipsTime > GAME.config.tipsTime) then
				local tips = GAME.config.tips
				local index = math.random(1,#tips)
				net_send("","message","> "..tips[index])
				GAME.game.tipsTime = 0
			end
			end
			
			cl.voteCoolDown = cl.voteCoolDown-t
			cl.afkTime = cl.afkTime+t
			if(cl.afkTime > GAME.config.afkTime) then
				if(cl.status ~= "afk" and cl.bot == "") then
					cl.status = "afk"
					cl.color = GAME.config.afkColor
					net_send("","message",cl.name.." set to afk automatically.")
				end
			end
		end
    
    	if(GAME.vote.active) then
    		GAME.vote.timer = GAME.vote.timer+t
    		if(GAME.vote.timer >= 20) then
    			GAME.vote.timer = 0
    			GAME.vote.active = false
    			local yesVotes = 0
    			local numClients = 0
    			for k,client in pairs(GAME.clients) do
    				if(client.status ~= "afk" and client.bot == "") then
    					numClients = numClients+1
    				end
           			if(client.vote == "yes") then
           				yesVotes = yesVotes+1
           			end
     			end
     			
     			  local c = clientWithName(GAME.vote.clientName)
     			   
     			local perc = (yesVotes/numClients)*100
     				net_send("","message","---------------------------------")
     			if(perc > 50) then
     				net_send("","message","Vote passed with "..perc.."%"..".")
     				
     				if(c ~= nil) then
     				if(GAME.vote.str == "0") then
     					c.adminLevel = 0
            			net_send("","message",c.name.." is ".."0normal")
            		elseif(GAME.vote.str == "+") then
            			c.adminLevel = 1
            			net_send("","message",c.name.." is ".."+plus")
            		elseif(GAME.vote.str == "@") then
            			c.adminLevel = 2
            			net_send("","message",c.name.." is ".."@admin")
            		end
            		else
            		if(GAME.vote.str == "0") then
            				setSavedClientAdminLevel(GAME.vote.clientUid,0)
            				net_send("","message",GAME.vote.clientName.." is ".."0normal")
            		elseif(GAME.vote.str == "+") then
            				setSavedClientAdminLevel(GAME.vote.clientUid,1)
            				net_send("","message",GAME.vote.clientName.." is ".."+plus")
            		elseif(GAME.vote.str == "@") then
            				setSavedClientAdminLevel(GAME.vote.clientUid,2)
            				net_send("","message",GAME.vote.clientName.." is ".."@admin")
            		end

            		end
     			else
     				net_send("","message","Vote failed with "..math.floor(perc).."%"..".")
     			end
     				net_send("","message","---------------------------------")
    		end
    		saveData()
    	end
   end



