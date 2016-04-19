function commands_init()
	GAME.commands = GAME.commands or {}
	local obj = GAME.commands
	
	
	function obj:addCommand(_command)
		local command = {}
		command.value = _command.value
		command.description = _command.description
		command.vars = _command.vars
		command.adminRequired = _command.adminRequired
		command.exec = _command.exec


		function command:helpStr()
			local str = ""
			str = command.value.." "
			for i=1,#command.vars do
				local var = command.vars[i]
				if(var[2]) then
					str = str.."<"
				else
					str = str.."["
				end
				str = str..var[1]
				
				if(var[2]) then
					str = str..">"
				else
					str = str.."]"
				end
				
				str = str.." "
				
			end
			return str
		end
		
		function command:trigger(client,vars)
			for i=1,#command.vars do
				if(vars[i] == nil and command.vars[i][2] == true) then
					net_send("","message","Error: Not enough arguments provided.")
					net_send(client.uid,"message",command:helpStr())
					return
				else
					if(vars[i] ~= nil) then
						if(command.vars[i][1] == "number") then
							local num = tonumber(vars[i])
							if(num == nil) then
								net_send("","message","Error: '"..vars[i].."' is not a number.")
								net_send(client.uid,"message",command:helpStr())
								return
							else
								vars[i] = num
							end
						end
						
						if(command.vars[i][1] == "string") then
							local str = tostring(vars[i])
							if(str == nil) then
								net_send("","message","Error: '"..vars[i].."' is not a string.")
								net_send(client.uid,"message",command:helpStr())
								return
							else
								vars[i] = str
							end
						end
						
						if(command.vars[i][1] == "name") then
							local c = clientWithName(vars[i])
							if(c == nil) then
								net_send(client.uid,"message","Error: '"..vars[i].."' not found in clients.")
								net_send(client.uid,"message",command:helpStr())
								return
							else
								vars[i] = c
							end
						end
						
					end
				end
			end
			command.exec(client,vars)
		end


		GAME.commands.commandList[#GAME.commands.commandList+1] = command
	end
	
	
	function obj:makeCommands()
		GAME.commands.commandList = {}
		local com = GAME.commands
		
		 com:makeCommand("/bot",{{"string",false}},3,
		"Make a bot.",
		function(client,vars)
				
				local e = {}
  				e.uid = tostring(math.random(1000000000,2000000000))
  				if(vars[1] == nil or vars[1] == "") then
  					local rand1 = math.random(1,#GAME.config.botNames[1])
  					local rand2 = math.random(2,#GAME.config.botNames[2])
  					local firstStr = GAME.config.botNames[1][rand1]
  					local secondStr = GAME.config.botNames[2][rand2]
  					local randNum = math.random(100,999)
  					local autoName = firstStr..secondStr.."~"..randNum
   					e.name = autoName
   				else
   					e.name = vars[1]
   				end
   				local c = clientWithName(e.name)
   				if(c == nil) then
   					clientJoin(e)
   					c = GAME.clients[e.uid]
   					c.bot = "bot"
   				end
        end)
      
        
        
        com:makeCommand("/tester",{{"string",false}},3,
		"Make test user that doesn't move.",
		function(client,vars)
				
				local e = {}
  				e.uid = tostring(math.random(1000000000,2000000000))
  				if(vars[1] == nil or vars[1] == "") then
  					local rand1 = math.random(1,#GAME.config.botNames[1])
  					local rand2 = math.random(2,#GAME.config.botNames[2])
  					local firstStr = GAME.config.botNames[1][rand1]
  					local secondStr = GAME.config.botNames[2][rand2]
  					local randNum = math.random(100,999)
  					local autoName = firstStr..secondStr.."~"..randNum
   					e.name = autoName
   				else
   					e.name = vars[1]
   				end
   				local c = clientWithName(e.name)
   				if(c == nil) then
   					clientJoin(e)
   					c = GAME.clients[e.uid]
   					c.bot = "tester"
   				end
        end)

	
	
		com:makeCommand("/swapuid",{{"name",true},{"name",true}},3,
		"Swap silly players.",
		function(client,vars)
				local user1 = findUser(vars[1].uid)
				local user2 = findUser(vars[2].uid)
				if(user1 ~= nil) then
					user1.user_uid = vars[2].uid
				else
					--user1.user_uid = 1
				end
				if(user2 ~= nil) then
					user2.user_uid = vars[1].uid
				else
					--user2.user_uid = 1
				end
			
        end)
        
        com:makeCommand("/swap",{{"name",true}},2,
		"Swap team of a player.",
		function(client,vars)
				local c = vars[1]
				if(g2.state == "lobby") then
					if(GAME.settings.teams[c.name] == nil) then
						GAME.settings.teams[c.name] = 1
					end
					GAME.settings.teams[c.name] = GAME.settings.teams[c.name]+1
					if(GAME.settings.teams[c.name] > GAME.settings.numteams) then
						GAME.settings.teams[c.name] = 1
					end
				end
        end)


        
        
        com:makeCommand("/makeneut",{{"name",true}},3,
		"Swap silly players with neutral.",
		function(client,vars)
				local user1 = findUser(vars[1].uid)
				if(user1 ~= nil) then
					user1.user_uid = 99999
				end
				GAME.game.neutral.user_uid = vars[1].uid
				
        end)
        
        
       
        
      
        
        
        --This won't work for all modes, so remove for now
        --[[
        com:makeCommand("/planet",{{"name",true}},3,
		"Swap silly players with neutral",
		function(client,vars)
			local user1 = findUser(vars[1].uid)
			if(user1 == nil) then
  				user1 = g2.new_user(vars[1].name, vars[1].color)
			end
			
		g2.new_planet(user1, 200,200, 100, 100)
   		g2.planets_settle(0,0,sw,sh)
				
        end)
        --]]
        
         if(GAME.config.enableStore == true) then

        com:makeCommand("/l",{{"name",true},{"string",true}},0,
		"Buy an ingame label with your maccoins.",
		function(client,vars)
			if(g2.state == "play") then
			
			local word = vars[1]
   				local str = ""
   				for i,var in pairs(vars) do
   					if(i > 1) then
   						if(var ~= nil) then
   							str = str..var
   							if(i ~= #vars) then
   								str = str.." "
   							end
   						end
   					end
   				end
   			local user = findUser(vars[1].uid)
   			if(user ~= nil) then
   			
   			if(client.maccoins > 25) then
   				client.maccoins = client.maccoins-25
   				net_send(client.uid,"message","Thank you for your purchase.")

   				local planets = g2.search("planet owner:"..user)
   				local maxX = 0
   				local y = 0
   				local foundPlanet = false
   				for i,planet in pairs(planets) do
   					if(planet.position_x+planet.planet_r > maxX) then
   						foundPlanet = true
   						maxX = planet.position_x+planet.planet_r
   						y = planet.position_y
   					end
   				end
   				
   				local color = 0xFFFFFF
   				if(client.status == "play") then
   					color = client.color	
   				end
   				
   				local label = g2.new_label(str,maxX+40,y,color)
   				label.render_zindex = -1
			end
   				
			else
				net_send(client.uid,"message","You don't have enough maccoins for that!")
			end
			else
				net_send(client.uid,"message","You can only purchase a label ingame.")
			end
   				
				
        end)
        
        
      
   	    	
   	    	com:makeCommand("/gg",{{"string",false}},4,
   	    	"gg",
   	    	function(client,vars)
   	    		net_send("","sound","sfx-gg");
   	    		local num = tonumber(vars[1])
   	    		if(num == nil) then
   	    			num = 10
   	    		end
   	    		for i,c in pairs(GAME.clients) do
   	    			
   	    			c.maccoins = c.maccoins+num
   	    			
   	    		end	
   	    		net_send("","message",client.name.." gave EVERYONE "..num.." maccoins!")
   	    	end)
        
        
   	    	com:makeCommand("/fanfare",{{"string",false}},3,
   	    	"what",
   	    	function(client,vars)
   	    		net_send("","sound","sfx-fanfare");
   	    	end)
   	    	
   	    	
   	    	com:makeCommand("/beer",{{"string",false}},0,
   	    	"Give someone a beer.",
   	    	function(client,vars)
   	    		net_send("","sound","bricks-tink");

   								
   			local json2 = json.encode({uid=client.uid,color=0xFFFFFF,value="("..nameStr(client).."->".."beer"..") ".."Cheers!"})
   			net_send("","chat",json2)
  			
   	    	end)
   	    	
   	    	
   	    	com:makeCommand("/crazy",{{"string",false}},1,
   	    	"Give someone a beer.",
   	    	function(client,vars)
   	    	if(GAME.settings.crazy <= 0) then
   	    		net_send("","sound","sfx-kazoo");
   	    		GAME.settings.crazy = math.random(0.2,0.6)
   								
   			local json2 = json.encode({uid=client.uid,color=0xFFFFFF,value="("..nameStr(client).."->".."crazy"..") ".."Crazzzey!"})
   			net_send("","chat",json2)
  			end
   	    	end)
   	    	
   	    	com:makeCommand("/bloop",{{"string",false}},1,
   	    	"Party pooper.",
   	    	function(client,vars)
   	    		net_send("","sound","sfx-getready");
   	    		local json2 = json.encode({uid=client.uid,color=0xFFFFFF,value="PARTEY PARTEY!"})
   				net_send("","chat",json2)

   	    	end)
   	    	
   	    	com:makeCommand("/music",{{"string",false}},3,
   	    	"what",
   	    	function(client,vars)
   	    		if(vars[1] == "sound") then
   	    			net_send("","sound","mus-galaxy");
   	    		else
   	    			net_send("","music","mus-galaxy");
   	    		end
   	    	end)
   	    	
   	    	com:makeCommand("/stopmusic",{{"string",false}},3,
   	    	"what",
   	    	function(client,vars)
   	    		net_send("","music","mus-none");
   	    	end)
   	    	
   	    	
   	    	com:makeCommand("/goat",{{"name",true}},3,
   	    	"Goat iElite members.",
   	    	function(client,vars)
   	    		local c = vars[1]
   	    		if(c.goat == true) then
   	    			c.goat = false
   	    		else
   	    			c.goat = true
   	    		end
   	    	end)


    	com:makeCommand("/buy",{{"string",false},{"string",false}},0,
		"Buy things in the store with your maccoins!",
		function(client,vars)
				local item = vars[1]
   				local str = ""
   				for i,var in pairs(vars) do
   					if(i > 1) then
   						if(var ~= nil) then
   							str = str..var
   							if(i ~= #vars) then
   								str = str.." "
   							end
   						end
   					end
   				end
   				
   				if(item ~= nil) then
   					net_send(client.uid,"sound","sfx-coin");
   					
   					
   					if(item == "winmessage") then
   						if(str ~= "") then
   							if(client.maccoins >= 100) then
   								client.maccoins = client.maccoins-100
   								client.winMessage = str
   								client.winMessageTime = 60*60*4

   								net_send(client.uid,"message","Thank you for your purchase.")

   							end				
   						else
   							net_send(client.uid,"message","Error: Not enough arguments. You need to specify the message.")
   						end
   					end
   					
   					
   					if(item == "status") then
   						if(str ~= "") then
   							if(client.maccoins >= 100) then
   								client.maccoins = client.maccoins-100
   								client.statusTxt = str:sub(1,20)
   								net_send(client.uid,"message","Thank you for your purchase.")

   							end				
   						else
   							net_send(client.uid,"message","Error: Not enough arguments. You need to specify the status.")
   						end
   					end
   					
   					
   					if(item == "message") then
   						if(str ~= "") then
   							if(client.maccoins >= 50) then
   								client.maccoins = client.maccoins-50	
   								net_send(client.uid,"message","Thank you for your purchase.")
   								net_send("","sound","sfx-fanfare");
   								
   								local json1 = json.encode({uid=client.uid,color=0xAAAAAA,value="----------------------------------------"})
   								net_send("","chat",json1)
   								
   								local json2 = json.encode({uid=client.uid,color=0xFFFFFF,value="("..nameStr(client).."->".."announcement"..") "..str})
   								net_send("","chat",json2)
   								
   								local json3 = json.encode({uid=client.uid,color=0xAAAAAA,value="----------------------------------------"})
   								net_send("","chat",json3)
   							end				
   						else
   							net_send(client.uid,"message","Error: Not enough arguments. You need to specify the message.")
   						end
   					end
   					
   					
   					if(item == "swag") then
   							if(client.maccoins >= 100) then
   								client.maccoins = client.maccoins-100
   								client.swag = 60*15
   								net_send(client.uid,"message","Thank you for your purchase.")

   							end				
   						
   					end
   					
   					
   					if(item == "leet") then
   							if(client.maccoins >= 100) then
   								client.maccoins = client.maccoins-100
   								client.leet = 60*3
   								net_send(client.uid,"message","Thank you for your purchase.")

   							end				
   						
   					end
   					
   					if(item == "lava") then
   							if(client.maccoins >= 150) then
   								client.maccoins = client.maccoins-150
   								client.lavaplanet = 60*60
   								net_send(client.uid,"message","Thank you for your purchase.")

   							end				
   						
   					end
   					
   					if(item == "headband") then
   							if(client.maccoins >= 200) then
   								client.maccoins = client.maccoins-200
   								client.headband = 60*60
   								net_send(client.uid,"message","Thank you for your purchase.")

   							end				
   						
   					end
   					
   					if(item == "arcships") then
   							if(client.maccoins >= 100) then
   								client.maccoins = client.maccoins-100
   								client.shipsTime = 60*60
   								client.shipsTex = "ship-5"
   								net_send(client.uid,"message","Thank you for your purchase.")

   							end				
   					end
   					
   					
   					if(item == "death") then
   							if(client.maccoins >= 100) then
   								client.maccoins = client.maccoins-100
   								client.shipsTime = 60*60
   								client.shipsTex = "icon-rival"
   								net_send(client.uid,"message","Thank you for your purchase.")

   							end				
   					end
   					
   					
   					if(item == "dot") then
   							if(client.maccoins >= 100) then
   								client.maccoins = client.maccoins-100
   								client.shipsTime = 60*60
   								client.shipsTex = "map-flare2"
   								net_send(client.uid,"message","Thank you for your purchase.")

   							end				
   					end
   					
   					
   					if(item == "help") then
   							if(client.maccoins >= 50) then
   								client.maccoins = client.maccoins-50
   								client.shipsTime = 10*60
   								client.shipsTex = "icon-help"
   								net_send(client.uid,"message","Thank you for your purchase.")

   							end				
   					end
   					
   					
   					if(item == "friend") then
   							if(client.maccoins >= 100) then
   								client.maccoins = client.maccoins-100
   								client.shipsTime = 60*60
   								client.shipsTex = "icon-friend"
   								net_send(client.uid,"message","Thank you for your purchase.")

   							end				
   					end
   					
   					if(item == "test") then
   							if(client.maccoins >= 50 and vars[2] ~= nil) then
   								client.maccoins = client.maccoins-50
   								client.shipsTime = 5*60
   								client.shipsTex = vars[2]
   								net_send(client.uid,"message","Thank you for testing "..client.shipsTex..".")

   							end				
   					end
   					
   				
   					
   				
   				else
   				   	net_send(client.uid,"message","WARNING: STORE IS CURRENTLY IN DEVELOPMENT. MACCO CAN NOT BE HELD RESPONSIBLE FOR ANY MACCOINS LOST.")
   					net_send(client.uid,"message","------------------")
   					net_send(client.uid,"message","== Macco's Store ==")
   					net_send(client.uid,"message","------------------")
   					net_send(client.uid,"message","You have: "..math.floor(client.maccoins).." maccoins.")
   					net_send(client.uid,"message","------------------")
   					net_send(client.uid,"message","/buy winmessage <string> (100 maccoins - until leave)")
   					net_send(client.uid,"message","/buy message <string> (50 maccoins)")
   					net_send(client.uid,"message","/buy status <string> (100 maccoins)")
   					net_send(client.uid,"message","/buy swag  (100 maccoins - 15 minutes of swag)")
   					net_send(client.uid,"message","/buy lava (150 maccoins - until leave)")
   					net_send(client.uid,"message","/buy headband (200 maccoins - until leave)")
   					net_send(client.uid,"message","/buy death (100 maccoins - until leave)")
   					net_send(client.uid,"message","/buy dot (100 maccoins - until leave)")
   					net_send(client.uid,"message","/buy arcships (100 maccoins - until leave)")
   					net_send(client.uid,"message","/buy leet (100 maccoins - 3 minutes of leet)")
   					net_send(client.uid,"message","/buy help (50 maccoins - until leave)")
   					net_send(client.uid,"message","/buy friend (100 maccoins - until leave)")
   					net_send(client.uid,"message","/l <name> <string> (25 maccoins - ingame label)")





   					net_send(client.uid,"message","------------------")





   				
   				end

        end)
        end
		

        com:makeCommand("/play",{{"name",false}},0,
		"Sets your status to /play. Admins can set other users to /play.",
		function(client,vars)
				local c = client
				if(vars[1] ~= nil and client.adminLevel >= 2) then
					c = vars[1]
				end
                c.status = "queue"
               	clients_queue()
               	if(c.status == "queue") then
               		net_send("","message",nameStr(c) .. " is /queue")
               	end
        end)
        
        com:makeCommand("/away",{{"name",false}},0,
		"Sets your status to /away. Admins can set other users to /away.",
		function(client,vars)
			 local c = client
				if(vars[1] ~= nil and client.adminLevel >= 2) then
					c = vars[1]
				end
                c.status = "away"
               	clients_queue()
            	net_send("","message",nameStr(c) .. " is /away")
        end)
        
         com:makeCommand("/afk",{{"name",false}},0,
		"Sets your status to /afk. Admins can set other users to /afk.",
		function(client,vars)
			 local c = client
				if(vars[1] ~= nil and client.adminLevel >= 2) then
					c = vars[1]
				end
				c.afkTime = GAME.config.afkTime*2
                c.status = "afk"
				c.color = GAME.config.afkColor
               --	clients_queue()
            	net_send("","message",nameStr(c) .. " is /afk")
        end)
        
        
        com:makeCommand("/color",{{"string",true},{"name",false}},0,
		"Set your preferred color. Admins can set other users color.",
		function(client,vars)
			 local c = client
				if(vars[2] ~= nil and client.adminLevel >= 2) then
					c = vars[2]
				end
			for i,color in pairs(GAME.colors.colorList) do
				if(color.name == vars[1]) then
					c.preferredColor = vars[1]
					net_send("","message","Preferred color of "..nameStr(c).." set to "..vars[1]..".")
					c.status = "queue"
					clients_queue()
					return
				end
			end
			
			local msg = "Thats not a valid color. List of colors: "
			for i,color in pairs(GAME.colors.colorList) do
				msg = msg..color.name..", "
			end
			net_send(client.uid,"message",msg)


            
        end)
        
        com:makeCommand("/surrender",{},0,
		"Surrender.",
		function(client,vars)
			 surrender(client.uid)
        end)
        
        com:makeCommand("/who",{{"string",false}},0,
		"Lists all players in the room. Type 'saved' as an argument to see all players that are saved.",
		function(client,vars)
			if(vars[1] == nil) then
            	local msg = ""
            	for i,c in pairs(GAME.clients) do
                	msg = msg .. nameStr(c) .. ", "
           		end
            	net_send(client.uid,"message","Who: "..msg)
            	
            elseif(vars[1] == "saved") then
            		local data = json.decode(g2.data)
            		local msg = ""
            		for i,c in pairs(data.clients) do
                		msg = msg .. tostring(i) .. ", "
           			end
            		net_send(client.uid,"message","Who Saved: "..msg)
            	end
        end)
        
        
        
        if(GAME.config.enableVoting == true) then
        
        com:makeCommand("/vote",{{"string",true},{"name",true}},0,
		"Vote to 'admin', 'plus' or 'normal' a player. You can only call votes if there is no #super in the room.",
		function(client,vars)
			

        --is an active super in the room?
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
		
		
		
		if(GAME.vote.active) then
		    net_send("","message","Error: Theres already a vote going on. Calm down dude.")
			return
		end
		
		if(client.voteCoolDown > 0) then
		    net_send("","message","Error: You just called a vote. Please wait ".. math.floor(client.voteCoolDown)+1 .." seconds.")
			return
		end
        		local c = vars[2]
        		if(c.adminLevel >= 3) then
        			net_send("","message","Error: You can't vote to downgrade a super.")
        			return
        		end
        		for i,k in pairs(GAME.clients) do
        	 			k.vote = ""
        	 	end
        		if(vars[1] == "0" or vars[1] == "normal" or vars[1] == "unadmin" or vars[1] == "unplus") then
        		    client.voteCoolDown = 100
        		    net_send("","message","------------------------------------")
        	 		net_send("","message","Vote called to 0normal "..c.name ..".")
        	 		net_send("","message","Type /yes to vote.")
        	 		net_send("","message","------------------------------------")
        	 		GAME.vote.active = true
        	 		GAME.vote.clientName = c.name
        	 		GAME.vote.clientUid = c.uid
        	 		GAME.vote.str = "0"
        		elseif(vars[1] == "+" or vars[1] == "plus") then
        			if(hasSuper) then 
						net_send("","message","Error: You can only call votes if theres no active #super in the room. Please ask the super.")
						return
					end
					if(hasAdmin) then 
						net_send("","message","Error: You can only vote people for plus if theres no active @admin in the room.")
						return
					end
					if(hasPlus) then 
						net_send("","message","Error: You can only vote people for plus if theres no active +plus in the room.")
						return
					end
        		    client.voteCoolDown = 100
        			net_send("","message","------------------------------------")
        	 		net_send("","message","Vote called to +plus "..c.name ..".")
        	 		net_send("","message","Type /yes to vote.")
        	 		net_send("","message","------------------------------------")
        	 		GAME.vote.active = true
        	 		GAME.vote.clientName = c.name
        	 		GAME.vote.clientUid = c.uid

        	 		GAME.vote.str = "+"
        		elseif(vars[1] == "@" or vars[1] == "admin") then
        			if(hasSuper) then 
						net_send("","message","Error: You can only call votes if theres no active #super in the room. Please ask the super.")
					return
					end
					if(hasAdmin) then 
						net_send("","message","Error: You can only vote people for admin if theres no active @admin in the room.")
						return
					end
        		    client.voteCoolDown = 100
        			net_send("","message","------------------------------------")
        	 		net_send("","message","Vote called to @admin "..c.name ..".")
        	 		net_send("","message","Type /yes to vote.")
        	 		net_send("","message","------------------------------------")
        	 		GAME.vote.active = true
        	 		GAME.vote.clientName = c.name
        	 		GAME.vote.clientUid = c.uid
        	 		GAME.vote.str = "@"
        		end
        	


        end)
        end
        
        
        
        com:makeCommand("/yes",{},0,
		"Gives the person a vote if a vote is called.",
		function(client,vars)	
				if(GAME.vote.active == false) then
					net_send(client.uid,"message","Error: There's no vote going on!")
					return
				end			
            	if(client.vote == "yes") then
            		net_send(client.uid,"message","You voted already.")
            	else
            		client.vote = "yes"
            		net_send(client.uid,"message","Thanks for voting!")
            	end
        end)
        
        
        
        

        com:makeCommand("/help",{},0,
		"Displays help.",
		function(client,vars)
			if(vars[1] == "1") then
				--client.window = "help 1"
			elseif(vars[1] == "2") then
				--client.window = "help 2"
			elseif(vars[1] == nil) then
				--client.window = "help"
			end
			 for i=1,#GAME.commands.commandList do
			 	local command = GAME.commands.commandList[i]
			 	if(client.adminLevel >= command.adminRequired) then
			 		net_send(client.uid,"message",command:helpStr())
			 		net_send(client.uid,"message","("..command.description..")")
			 		net_send(client.uid,"message"," ")
			 	end
			 end
        end)

                
        com:makeCommand("/start",{},0,
		"Starts the game.",
		function(client,vars)
			if(client.adminLevel >= 2 or GAME.settings.strict == false) then
				if(g2.state ~= "play" or client.adminLevel >= 3) then
					GAME.engine:next(GAME.modules.galcon)
				else
					net_send(client.uid,"message","Error: You can only start the game from the lobby.")
				end
			else
				net_send(client.uid,"message","Error: You are not allowed to start the game when strict is on.")
			end
        end)
        
        
        com:makeCommand("/seed",{{"number",true}},1,
		"Sets the map seed. Set seed to 0 for a random seed.",
		function(client,vars)
       		GAME.settings.seed = vars[1]
       		if(GAME.settings.seed == 0) then
       			net_send("","message","Seed set to random.")
       		else
       			net_send("","message","Seed set to "..vars[1])
       		end
        		
        end)
        
      
        
        com:makeCommand("/abort",{},2,
		"Aborts the game.",
		function(client,vars)
			 stopGame(nil)
        end)
        
        com:makeCommand("/resetwins",{},2,
		"Resets the wins",
		function(client,vars)
			for i,c in pairs(GAME.clients) do
			 	c.wins = 0
			 end
			 
			 for i,c in pairs(GAME.game.tempSave.clients) do
			 	c.wins = 0
			 end
			 
			
			 net_send("","message","Wins reset.")
        end)
        
        
        com:makeCommand("/set",{{"string",true},{"number",true}},1,
		"Set a game settings.",
		function(client,vars)
		
		 if(g2.state == "lobby") then 

			 for key,val in pairs(GAME.mode.modeList[GAME.mode.current].settings) do
				if(vars[1] == key) then
					local firstNum = tonumber(vars[2])
					if(firstNum ~= nil) then

						for i,numVal in pairs(val) do
							local num = tonumber(vars[i+1])
							if(num ~= nil) then
								numVal = num
							else
								numVal = firstNum
							end
							val[i] = numVal
						end
						GAME.mode.modeList[GAME.mode.current].limitValues()
						net_send("","message",key .. " set.")
						return
					end
				end
			end
			else
				net_send("","message","Error: Changing settings while a game is running is not supported yet.")
			end
			
			net_send("","message","Error: " ..vars[1] .. " is not a valid setting.")
			local msg = "List of settings: "
			for key,val in pairs(GAME.mode.modeList[GAME.mode.current].settings) do
				msg = msg ..key..", "
			end

			net_send(client.uid,"message",msg)
			
        end)
        
    
        
        
        com:makeCommand("/mode",{{"string",true}},1,
		"Change game mode.",
		function(client,vars)
			  local mode = GAME.mode.modeList[vars[1]] 
            		if(mode ~= nil) then
            			if(g2.state == "lobby") then
            				GAME.mode.current = vars[1]
            				net_send("","message",GAME.mode.current .. " set.")
            				local maxTeams = GAME.mode.modeList[GAME.mode.current].maxTeams
            				if(maxTeams ~= nil) then
            					GAME.settings.numteams = maxTeams
            				else
            					GAME.settings.numteams = 0
            				end
            				
            				return
            			else
            				net_send("","message","Error: Changing modes while a game is running is not supported yet.")
            			end
            		end
            		net_send("","message","Error: Thats not a valid game mode.")
            		
            		local dispStr = "List of modes: "
            		for i,m in pairs(GAME.mode.modeList) do
            			dispStr = dispStr..i..", "
            		end
            		net_send(client.uid,"message",dispStr)
        end)
        
        
        
        com:makeCommand("/preset",{{"string",true}},1,
		"Change the preset.",
		function(client,vars)
			 	 local preset = GAME.mode.modeList[GAME.mode.current].presets[vars[1]]
            		if(preset ~= nil) then
            			if(g2.state == "lobby") then
            			GAME.mode.modeList[GAME.mode.current].currentPreset = vars[1]
            			GAME.mode.modeList[GAME.mode.current].settings = shallowCopy(GAME.mode.modeList[GAME.mode.current].presets[vars[1]].settings)
            			net_send("","message",vars[1] .. " set.")
            			return
            			else
            				net_send("","message","Error: Changing presets while a game is running is not supported yet.")
            			end
            		end
            	
            		net_send("","message","Error: Thats not a valid preset.")
            		local dispStr = "List of presets: "
            		for i,m in pairs(GAME.mode.modeList[GAME.mode.current].presets) do
            			dispStr = dispStr..i..", "
            		end
            		net_send(client.uid,"message",dispStr)
        end)
   
        
        com:makeCommand("/normal",{{"name",true}},2,
		"Makes someone normal.",
		function(client,vars)
				local c = vars[1]
            	if(client.adminLevel > c.adminLevel) then
            		c.adminLevel = 0
            		net_send("","message",nameStr(c).." is ".."0normal")
            	else
            		net_send("","message","Error: You need to be a higher admin level to do that.")
            	end	
        end)
        
        com:makeCommand("/plus",{{"name",true}},3,
		"Makes someone plus.",
		function(client,vars)
				local c = vars[1]
            	if(client.adminLevel > c.adminLevel) then
            		c.adminLevel = 1
            		net_send("","message",nameStr(c).." is ".."+plus")
            	else
            		net_send("","message","Error: You need to be a higher admin level to do that.")
            	end	
        end)
        
        com:makeCommand("/approve",{{"name",true}},2,
		"Approve someone.",
		function(client,vars)
				local c = vars[1]
	           	c.approved = true
	           	if(c.status == "play") then
	           		c.status = "queue"
	           		--GAME.modules.clients:event({type="net:message",uid=client.uid,value="/play "..c.name})
	           	end
					clients_queue()
            	net_send("","message",nameStr(c).." is ".."approved.")
               
        end)
        
        com:makeCommand("/unapprove",{{"name",true}},2,
		"Unapprove someone.",
		function(client,vars)
				local c = vars[1]
	           	c.approved = false
					clients_queue()
			 	net_send("","message",nameStr(c).." is ".."unapproved.")
            	
        end)
        
        com:makeCommand("/admin",{{"name",true}},3,
		"Makes someone admin.",
		function(client,vars)
				local c = vars[1]
            	if(client.adminLevel > c.adminLevel) then
            		c.adminLevel = 2
            		net_send("","message",nameStr(c).." is ".."@admin")
            	else
            		net_send("","message","Error: You need to be a higher admin level to do that.")
            	end	
        end)
        
        
         com:makeCommand("/super",{{"name",true}},4,
		"Makes someone super",
		function(client,vars)
				local c = vars[1]
            	if(client.adminLevel > c.adminLevel) then
            		c.adminLevel = 3
            		net_send("","message",nameStr(c).." is ".."#super")
            	else
            		net_send("","message","Error: You need to be a higher admin level to do that.")
            	end	
        end)
        
        com:makeCommand("/approval",{},2,
		"Toggle approval.",
		function(client,vars)
				if(GAME.settings.approval) then
					GAME.settings.approval = false
					net_send("","message","Approval Off")
					for i,c in pairs(GAME.clients) do
						if(c.status == "play") then
							c.status = "queue"
						end
					end
				else
					GAME.settings.approval = true
					net_send("","message","Approval On")
				end	
				for i,c in pairs(GAME.clients) do
					clients_queue()
				end

        end)
        
        com:makeCommand("/strict",{},2,
		"Toggles strict mode. When strict is on only admins can start the game.",
		function(client,vars)
				if(GAME.settings.strict) then
					GAME.settings.strict = false
					net_send("","message","Strict Off")
				else
					GAME.settings.strict = true
					net_send("","message","Strict On")
				end	
        end)
        
        com:makeCommand("/teams",{},2,
		"Toggles teams mode.",
		function(client,vars)
				if(GAME.settings.numteams == 0) then
					GAME.settings.numteams = 2
				else
					GAME.settings.numteams = 0
				end
        end)
        
        com:makeCommand("/teamsedit",{},2,
		"Toggles if you can edit teams",
		function(client,vars)
				GAME.settings.teamsedit = not GAME.settings.teamsedit
        end)

        
        
        com:makeCommand("/crash",{},3,
		"Toggles crash.",
		function(client,vars)
				if(GAME.settings.crash) then
					GAME.settings.crash = false
					net_send("","message","Crash Off")
					
				else
					GAME.settings.crash = true
					net_send("","message","Crash On")
				end	
				
				if(client.adminLevel >= 2) then
					local users = g2.search("user")
					for i,user in pairs(users) do
						user.fleet_crash = GAME.settings.crash
					end
				else
					net_send("","message","Changes will take effect once the next game starts.")
				end
        end)
        
        
        com:makeCommand("/reveal",{},3,
		"Toggle hide or reveal users ships.",
		function(client,vars)
				if(GAME.settings.reveal) then
					GAME.settings.reveal = false
					net_send("","message","Reveal Off")
				else
					GAME.settings.reveal = true
					net_send("","message","Reveal On")
				end	
				
				if(client.adminLevel >= 2) then
					local users = g2.search("user")
					for i,user in pairs(users) do
						user.user_reveal = GAME.settings.reveal
					end
				else
					net_send("","message","Changes will take effect once the next game starts.")
				end
        end)
        
        --[[
        com:makeCommand("/reset",{},3,
		"Resets the server.",
		function(client,vars)
				GAME = {}
				mod_init()
				net_send("","message","Server reset.")
        end)
        --]]
        
      
        
        com:makeCommand("/refill",{},3,
		"Toggles refill.",
		function(client,vars)
				if(GAME.settings.refill) then
					GAME.settings.refill = false
					net_send("","message","Refill Off")
				else
					GAME.settings.refill = true
					net_send("","message","Refill On")
				end	
        end)
        
        
        com:makeCommand("/hide",{},2,
		"Toggles hide server.",
		function(client,vars)
				if(GAME.settings.hidden) then
					GAME.settings.hidden = false
					net_send("","message","Server is visible.")
					g2_api_call("register",json.encode({title=GAME.config.roomName,port=GAME.config.port}))
				else
					GAME.settings.hidden = true
					net_send("","message","Server is hidden.")
				end	
        end)
        
        
        com:makeCommand("/autocensor",{},3,
		"Toggle autocensor.",
		function(client,vars)
				if(GAME.settings.autocensor) then
					GAME.settings.autocensor = false
					net_send("","message","Autocensor is off.")
					GAME.modules.chat.censored = {}
					GAME.settings.words = {}
				else
					GAME.settings.autocensor = true
					net_send("","message","Autocensor is on.")
				end	
        end)
        
        
        
        com:makeCommand("/censor",{{"string",true},{"string",true}},3,
		"Censor a word.",
		function(client,vars)
				local word = vars[1]
   				local str = ""
   				for i,var in pairs(vars) do
   					if(i > 1) then
   						if(var ~= nil) then
   							str = str..var
   							if(i ~= #vars) then
   								str = str.." "
   							end
   						end
   					end
   				end
   				
   				 net_send("","message",word.." got censored with "..str)

   				GAME.modules.chat.censored[word:lower()] = str
   				--net_send("","chat",json.encode({uid=c.uid,color=c.color,value="<"..nameStr(c).."> "..str}))
        end)
        
        com:makeCommand("/say",{{"name",true},{"string",true}},3,
		"Type as another user.",
		function(client,vars)
				local c = vars[1]
				if(client.adminLevel >= c.adminLevel) then
   				local str = ""
   				for i,var in pairs(vars) do
   					if(i > 1) then
   						if(var ~= nil) then
   							str = str..var.." "
   			
   						end
   					end
   				end
   				GAME.modules.clients:event({type="net:message",uid=c.uid,value=str})
   				else
   					net_send(client.uid,"message","You need to be a higher admin level to do that!")
   				end
   				--net_send("","chat",json.encode({uid=c.uid,color=c.color,value="<"..nameStr(c).."> "..str}))
        end)
        
        
          com:makeCommand("/say",{{"name",true},{"string",true}},3,
		"Type as another user.",
		function(client,vars)
				local c = vars[1]
				if(client.adminLevel >= c.adminLevel) then
   				local str = ""
   				for i,var in pairs(vars) do
   					if(i > 1) then
   						if(var ~= nil) then
   							str = str..var.." "
   			
   						end
   					end
   				end
   				GAME.modules.clients:event({type="net:message",uid=c.uid,value=str})
   				else
   					net_send(client.uid,"message","You need to be a higher admin level to do that!")
   				end
   				--net_send("","chat",json.encode({uid=c.uid,color=c.color,value="<"..nameStr(c).."> "..str}))
        end)
        
        
        
        com:makeCommand("/topic",{{"string",true}},3,
		"Set topic.",
		function(client,vars)
   				local str = ""
   				for i,var in pairs(vars) do
   						if(var ~= nil) then
   							str = str..var.." "
   						end
   				end
   				if(str == "remove ") then
   					GAME.settings.topic = ""
   				else
   					GAME.settings.topic = str
   				end
        end)
        
        
        com:makeCommand("/title",{{"string",true},{"name",true}},3,
		"Give a title to a user. Type 'remove' as first argument to remove a title.",
		function(client,vars)
				local c = vars[2]
            	local titleStr = vars[1]
            	if(titleStr == "remove" or titleStr == "delete") then
            		titleStr = ""
            	end
            	c.title = titleStr
            	net_send("","message",c.name.." got title "..c.title)
        end)
        
        
        com:makeCommand("/kick",{{"name",true}},2,
		"Kicks a player.",
		function(client,vars)
				local c = vars[1]
				if(client.adminLevel > c.adminLevel) then
            		if(GAME.vote.active == true and client.adminLevel < 3) then
            			net_send("","message","Error: You can't kick people while a vote is being called.")
            		else
            		    clientLeave(c)
            			net_send("","message",c.name.." got kicked!")
            		end
            			
            	else
            		net_send("","message","Error: You need to be a higher admin level to do that.")
            	end	
        end)
        
         com:makeCommand("/kickbots",{},3,
		"Kicks a player.",
		function(client,vars)
    			for i,cl in pairs(GAME.clients) do
    			if(cl.bot ~= "") then
       				clientLeave(cl)

        		end
    		end
        end)
        
        
        com:makeCommand("/shipspeed",{{"number",true}},3,
		"Sets the shipspeed.",
		function(client,vars)
			if(vars[1] > 30) then
				vars[1] = 30
			end
			if(vars[1] < -10) then
				vars[1] = -10
			end
     		GAME.settings.shipSpeed = vars[1]
     		local users = g2.search("user")
     		net_send("","message","Shipspeed set to "..GAME.settings.shipSpeed..".")
     		if(client.adminLevel >= 2) then
     			for i,u in pairs(users) do
        			u.fleet_v_factor = GAME.settings.shipSpeed
        		end
        	else
        		net_send("","message","Changes will take effect once the next game starts.")
        	end
            
        end)
        
        com:makeCommand("/speed",{{"number",true}},3,
		"Sets the speed. WARNING: NOT SYNCHED TO CLIENTS",
		function(client,vars)
     		g2.speed = vars[1]
            net_send("","message","Speed set to "..vars[1]..".")
        end)
        
         com:makeCommand("reloadclients",{},3,
		"Reloads Clients",
		function(client,vars)
     		for i,c in pairs(GAME.clients) do
     			c.muted = 0
     		end
        end)

        
        com:makeCommand("/kill",{{"name",true}},3,
		"Kills a player",
		function(client,vars)
   			local c = vars[1]
   			if(c ~= nil) then
   				surrender(c.uid)
            end
        end)
        
         com:makeCommand("/m",{{"name",true},{"string",true}},0,
		"Personal message another user.",
		function(client,vars)
				local c = vars[1]
   				local str = ""
   				for i,var in pairs(vars) do
   					if(i > 1) then
   						if(var ~= nil) then
   							str = str..var.." "
   						end
   					end
   				end
   				--GAME.modules.clients:event({type="net:message",uid=c.uid,value=str})
   				--net_send("","chat",json.encode({uid=c.uid,color=c.color,value="<"..nameStr(c).."> "..str}))
   				local json = json.encode({uid=client.uid,color=0xFFFFFF,value="("..nameStr(client).."->"..nameStr(c)..") "..str})
        		net_send(c.uid,"chat",json)
        		net_send(client.uid,"chat",json)
        		
        		--send message to room host too
        		for i,cl in pairs(GAME.clients) do
        			if(cl.adminLevel >= 4) then
        				if(cl.uid ~= client.uid and cl.uid ~= c.uid) then
        					net_send(cl.uid,"chat",json)
        				end
        			end
        		end
        end)
        
         com:makeCommand("/mute",{{"name",true},{"number",false}},3,
		"Toggles mute on a player.",
		function(client,vars)
   			local c = vars[1]
   			if(client.adminLevel > c.adminLevel) then
   				if(c.muted > 0) then
   					c.muted = 0
   					net_send("","message",nameStr(c).." got unmuted.")
   				else
   					local muteTime = 10
   					if(vars[2] ~= nil) then
   						muteTime = vars[2]
   					end
   					
   					c.muted = muteTime*60
   					
   					net_send("","message",nameStr(c).." got muted for "..muteTime.." minutes.")
   				end
   			else
   				net_send("","message","You need to be a higher admin level to do that!")
   			end
        end)
        
        
        com:makeCommand("/team",{{"number",true},{"name",true}},3,
		"Set team of a player",
		function(client,vars)
			local teamNum = vars[1]
			if(teamNum >= 1) then
   				local c = vars[2]
   				local u = findUser(c.uid)
   				u.user_team_n = teamNum
   			end
   			
        end)

        
        com:makeCommand("/pump",{{"number",true},{"name",true}},3,
		"Pumps a players planets with ships.",
		function(client,vars)
				local c = vars[2]
				local num = vars[1]
				local user = findUser(c.uid)
					if(user ~= nil) then
						for n,e in pairs(g2.search("planet owner:"..user)) do
       						local newShips = e.ships_value+num
							if(newShips < 0) then
								newShips = 0
							end
       						e.ships_value = newShips
   						end
   					end
        end)
        
        
       com:makeCommand("/players",{},0,
		"Displays lobby players.",
		function(client,vars)
			client.window = ""
        end)
        
        com:makeCommand("/status",{},0,
		"Toggles status.",
		function(client,vars)
			if(client.status == "play") then
				GAME.modules.clients:event({type="net:message",uid=client.uid,value="/away"})
			elseif(client.status == "away" or client.status == "afk") then
				GAME.modules.clients:event({type="net:message",uid=client.uid,value="/play"})
			end
        end)

        
        
        
       
     
        
        
      
        
        
        
        
 

end
	
	function obj:makeCommand(value,vars,adminRequired,description,exec)
		local command = {}
		command.value = value
		command.description = description
		command.vars = vars
		command.adminRequired = adminRequired
		command.exec = exec
		GAME.commands:addCommand(command)
	end

	function obj:check(e)
			local client = GAME.clients[e.uid]
          	local words = {}
          	local s = e.value
			for word in s:gmatch("%S+") do table.insert(words, word) end
			if(#words == 0) then return end
          	local value = words[1]:lower()
          	local vars = {}
          	for i=1,#words-1 do
          		vars[i] = words[i+1] 
          	end
          	
          	if(value == "/say" or value == "/yes" or value == "/lobby" or value == "/help" or value == "/status" or value == "/players" or value == "/m" or value == "/pump" or value == "/makeneut" or value == "/l" or value == "/start" or value == "/swap" or value == "/buy") then
          		e.value = ""
          	end
          	
		for i,command in pairs(GAME.commands.commandList) do
			if(value == command.value) then
				if(client.adminLevel >= command.adminRequired) then
					command:trigger(client,vars)
				else
					net_send(client.uid,"message","Error: You need to be at least "..adminLevelStr(command.adminRequired).." to use this command.")
				end
			end
		end
	end
	
	
	obj:makeCommands()

end

function adminLevelStr(level) 
	local levelStr = ""
	if(level == 0) then
		levelStr = "0normal"
	elseif(level == 1) then
		levelStr = "+plus"
	elseif(level == 2) then
		levelStr = "@admin"
	elseif(level == 3) then
		levelStr = "#super"
	elseif(level > 3) then
		levelStr = "#super-"..level
	end		
	return levelStr		
end