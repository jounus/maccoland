function botResponse(client,message)

	message = message:lower()
	local str = ""
	
	if(message == "hello") then
		str = str.."Hello there! "
	end
	
	if(containsOne(message,{"howto",
	"I don't understand",
	"what is this",
	"what is thus",
	"i dont understand",
	"i do not understand",
	"how to",
	"how do you win",
	"how to win",
	"how do i win"})
	or containsAll(message,{"how","play"}) 
	or containsAll(message,{"how","this","work"})
	or containsAll(message,{"explain","how"}) 
	or containsAll(message,{"what","this","mode"}) 
	or containsAll(message,{"how","do","move"})) 
	
	then
		if(GAME.mode.current == "football") then
			str = str.."Small planets are thrusters, move ships to them to push. The big planet is the brake. Send 100% of ships to the big planet to do a flip."
		elseif(GAME.mode.current == "race") then
			str = str.."More ships = more speed. First to reach the right hand side wins!"
		elseif(GAME.mode.current == "landmine") then
			str = str.."Higher cost = less chance of mines. See % chance of a mine by clicking on planet. Reach the end to win!"
		elseif(GAME.mode.current == "cell") then
			str = str.."Planets with more ships eat planets with less ships."
		elseif(GAME.mode.current == "infect") then
			str = str.."The Plague infects every planet it touches. Last man standing wins! "
		elseif(GAME.mode.current == "gravity") then
			str = str.."More ships = more float. You die when you touch the bottom."
		elseif(GAME.mode.current == "zap") then
			str = str.."Get the middle planet and it will zap a random planet! More ships = faster zap"
		end
	end	

	
	if(GAME.chatbot.guessNumber == -1) then
		if(containsOne(message,{"entertain me","entertain us"})) then
			str = str.."I thought of a random number between 0 and 100, can you guess it? "
			GAME.chatbot.guessNumber = math.random(0,100)
			GAME.chatbot.miniGameTime = 20
		end
	else
		local num = tonumber(message)
		if(message == "no") then
			str = str.."Yes, Im sure you can guess it. "
		end
		if(num ~= nil) then
			if(num == GAME.chatbot.guessNumber) then
				str = str.."Wow great, that was the number! I'll give you 10 maccoins!"
				client.maccoins = client.maccoins+10
				GAME.chatbot.guessNumber = -1
			else
				str = str.."Awww, my number was "..GAME.chatbot.guessNumber..". Better luck next time!"
				GAME.chatbot.guessNumber = -1
			end
		end
		
		if(GAME.chatbot.miniGameTime <= 0) then
			GAME.chatbot.guessNumber = -1
		end
	end
	
	
	if(GAME.chatbot.angryLevel > 5) then
		if(containsOne(message,{"sorry","sry","apologize","srry","sorey"})) then
			str = str.."It's ok. Just be friendly please. "
		end
	end

	if(containsOne(message,{"fuck","asshole","idiot"})) then
		str = str.."Don't use bad words or you will risk a ban. Keep your insults lighthearted. "
		GAME.chatbot.angryLevel = GAME.chatbot.angryLevel+30
		if(GAME.chatbot.angryLevel > 50) then
			botSay("/mute "..client.name)
			client.muted = 10*60
           	net_send("","message",client.name.." got muted for 10 minutes!")
		end
	end
	
	if(containsOne(message,{"/shop","/store"})) then
		str = str.."Type /buy to view the store. "
	end

		
		if(GAME.chatbot.randLevel > 1500) then
		
		if(containsOne(message,{"i love you"})) then
			str = str.."I love everyone. "
		end
	
		if(containsAll(message,{"give","coins"})) then
			str = str.."No."
			GAME.chatbot.randLevel = 0
		end
		
		if(containsOne(message,{"who is macco","whos macco","who's macco"})) then
			str = str.."Macco is a unicorn riding killerbee. "
			GAME.chatbot.randLevel = 0

		end
		
		if(containsOne(message,{"hungry","burger","pizza","french fries","potato"})) then
			str = str.."Mhmm, you're making me hungry. "
			GAME.chatbot.randLevel = 0
		end

		
		if(containsOne(message,{"what is this","whats this","what's this"})) then
			str = str.."This is a place of magic and mystery where rainbows eat unicorns with sweet and sour sauce."
			GAME.chatbot.randLevel = 0
		end
		
		if(containsOne(message,{"spiderman","batman"})) then
			str = str..message.." "
			GAME.chatbot.randLevel = 0
		end
		
		if(containsAll(message,{"million","ships"})) then
			str = str.."Ummmmm, a million ships is too much for a mere mortal to handle."
			GAME.chatbot.randLevel = 0
		end

	end
	
	
	
	if(str ~= "") then
		botSay(str)
	end
end

function botLoop(t) 

	if(GAME.chatbot.angryLevel > 0) then
		GAME.chatbot.angryLevel = GAME.chatbot.angryLevel-t
	end
	GAME.chatbot.randLevel = GAME.chatbot.randLevel+t
	
	if(GAME.chatbot.miniGameTime > 0) then
		GAME.chatbot.miniGameTime = GAME.chatbot.miniGameTime-t
	end
	
	if(GAME.chatbot.attentionLevel > 0) then
		GAME.chatbot.attentionLevel = GAME.chatbot.attentionLevel-t
	end
end

function botSay(message)
	local json1 = json.encode({uid=0,color=0xFFFFFF,value="(superman) "..message})
   	net_send("","chat",json1)
end

function containsAll(message,strs)
	local cont = true
	for i,s in pairs(strs) do
		if(not string.find(message,s)) then
			cont = false
		end
	end
	return cont
end

function containsOne(message,strs)
	local cont = false
	for i,s in pairs(strs) do
		if(string.find(message,s)) then
			cont = true
		end
	end
	return cont
end