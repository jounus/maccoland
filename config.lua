function config_init()
	GAME.config = {
		roomName = "Maccoland",
		version = "0.97",
		port = "23099",
		
		--seconds of inactivity required for auto-afk
		afkTime = 180,
		
		afkColor = 0x222222,
		awayColor = 0x777777,
		
		-- time between bot calls
		botWait = 0.1,
		
		-- time between tips
		tipsTime = 1000000000000000,
		
		botNames = {{"Rich","Ripe","Glossy","Silly","Yellow","Brown","Saggy","Grand","Bad","Lovely","Fatal","Angry","Lame","Crazy","Lively","Wabba"},	{"Pilot","Rebel","Turtle","Potato","Bird","Clown","Apple","Tea","Crayon","Piano","Noob","Kid","Granny","Snappa","Bottle","Kitchen"}},
	
	tips = {"Thank you for keeping the language clean in maccoland.","+Plus users can change the settings of the game, but can't do anything ingame.","Type /buy to look at the store and your maccoin balance.","You can vote to unadmin people by typing /vote normal <name>","Plus users can change presets by typing /preset name","Please don't use rude language anywhere on maccoland, or you'll risk a ban.","You can private message people by typing /m <name> <message>","You earn maccoins as long as you are in the server and not afk.","Thank you for using admin powers responsibly.","If an @admin or +plus user leaves the server, it will expire after 15 minutes.","Thank you for being respectful to eachother.","If you are not sure what the commands are just type /help","Never kick someone for no reason, or you'll risk getting banned.","+Plus users can change the mode by typing /mode name","A quick way to surrender is to just type 's'"},
	
	
	--//////NEW IN 0.97 ///////
		enableChatbot = true,
		enableVoting = true,
		enableStore = true,
		
		
		-- Server will be hidden on startup if set to true. Type /hide to toggle hide.
		hideOnStart = true,
		
		-- Available modes in this server. Leave empty to make all available.
		-- Note: Some modes might not be as robust as others, and may lag your server.
		-- Example: availableModes = {"football","race"}
		availableModes = {},
		
		
		--Set topic to empty string "" to hide it
		topic = ""
		
		--//////END NEW IN 0.97 ///////////
	
	}	
	GAME.config.welcomeMsgs = {"Welcome to "..GAME.config.roomName.." v"..GAME.config.version.."!","Type /help to get started."}

end