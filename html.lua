local function getrank(v) -- Determine user rank icon hex
	local flag = 1
	local star = 1
	local wing = 1
	
	
	local rank={'1','2','3','4','5','6','7','8','9','a'}
	
	flag = flagRank(v.wins)
	flag = rank[flag]
	
	wing = wingRank(v.maccoins)
	wing = rank[wing]
	
	star = starRank(v.timeInServer)
	star = rank[star]
	

	return flag..star..wing
end

function wingRank(m)
	if(m < 25) then
		return 1
	elseif(m < 50) then
		return 2
	elseif(m < 100) then
		return 3
	elseif(m < 200) then
		return 4
	elseif(m < 400) then
		return 5
	elseif(m < 800) then
		return 6
	elseif(m < 1600) then
		return 7
	elseif(m < 3200) then
		return 8
	elseif(m < 6400) then
		return 9
	else
		return 10
	end
	return 1
end

function flagRank(wins)
	if(wins == 0) then
		return 1
	elseif(wins < 2) then
		return 2
	elseif(wins < 4) then
		return 3
	elseif(wins < 6) then
		return 4
	elseif(wins < 12) then
		return 5
	elseif(wins < 20) then
		return 6
	elseif(wins < 35) then
		return 7
	elseif(wins < 55) then
		return 8
	elseif(wins < 100) then
		return 9
	else
		return 10
	end
	return 1
end

function starRank(s)
	if(s < 60) then
		return 1
	elseif(s < 120) then
		return 2
	elseif(s < 300) then
		return 3
	elseif(s < 600) then
		return 4
	elseif(s < 1200) then
		return 5
	elseif(s < 2400) then
		return 6
	elseif(s < 4000) then
		return 7
	elseif(s < 6500) then
		return 8
	elseif(s < 10000) then
		return 9
	else
		return 10
	end
	return 1
end



local function hex(n,offset) -- Convert number to 6-digit color hex.
	-- offset is a decimal range -1 to 1 which alters the dimness/brightness of the output.
	local t={'0','1','2','3','4','5','6','7','8','9','a','b','c','d','e','f'}
	local c={}
	for d=2,0,-1 do
		for i=1,256 do
			if i*256^d>n then
				c[#c+1]=i-1
				n=n-(i-1)*256^d
				break
			end
		end
	end
	offset=math.min(1,math.max(-1,offset or 0))
	for i=1,#c do
		if offset>0 then
			c[i]=math.min(255,math.floor((255-c[i])*offset/2+c[i]+.5))
		elseif offset<0 then
			c[i]=math.max(0,math.floor(c[i]*(1+offset)+.5))
		end
	end
	local s=""
	for i=1,#c do
		s=s..t[math.floor(c[i]/16)+1]..t[c[i]%16+1]
	end
	return s
end
local colorset={
	red=   0xff0000, green=0x00ff00,      blue=0x0000ff,cyan=0x00ffff,magenta=0xff00ff,yellow=0xffff00,white=0xffffff,
	orange=0xff8800,  lime=0x88ff00,    purple=0x8800ff, sky=0x88ffff,   pink=0xff88ff,pastel=0xffff88,
	maroon=0xff0088,marine=0x00ff88,      aqua=0x0088ff,
	salmon=0xff8888,  mint=0x88ff88,periwinkle=0x8888ff
}
colors=function()return{
	0x0000ff,0xff0000,0x00ff00,0x00ffff,0xff00ff,0xffff00,0xffffff,
	0xff8800,0x88ff00,0x8800ff,0x88ffff,0xff88ff,0xffff88,
	0xff0088,0x00ff88,0x0088ff,
	0xff8888,0x88ff88,0x8888ff
}end
local fixcolor={ -- brightness shift hardcoded for these colors
	[0x555555]="9e9e9e";
	[0xff0000]="ff6e6e";
	[0x0000ff]="6e6eff";
	[0x8800ff]="ff44ff";
}

-- Tab HTML --
local function tabs(client)
	local substitute=function(s)return s:gsub('$(%w+)',function(i)return({
		lobby =client.window:sub(1,4)=='help'and'tab'or'tab0'; -- Lobby window is active
		help  =client.window:sub(1,4)=='help'and'tab0'or'tab'; -- Help window is active
		status=client.status;                                  -- Client status icon
		title ="Store";
	})[i]or''end)end
	return substitute[[<table><tr>
		<td><input width='20%'type='button' disabled='true'pseudo='first'class='tab'/>
		<td><input width='20%'type='button' onclick ='/lobby'value='Lobby'icon='icon-lobby'class='$lobby'/>
		<td><input width='20%'type='button' onclick ='/status'value='Status'icon='icon-$status'class='tab'>
		<td><input width='20%'type='button' onclick ='/buy'    value='$title'icon='icon-galaxy'class='tab'/>
		<td><input width='20%'type='button' onclick ='/help'value='Help'icon='icon-help'pseudo='last'class='$help'>
	</table>]]
end

-- Help HTML --
local clist={'random'}
for _,v in pairs(colorset)do
	clist[#clist+1]=_
end
local layout={
	{menu="Instructions",icon="icon-member",
		{title="Instructions",
			-- for i=1,#GAME.commands.commandList do
			 	--local command = GAME.commands.commandList[i]
			 	--if(client.adminLevel >= command.adminRequired) then
			 	--	net_send(client.uid,"message",command:helpStr())
			 	--	net_send(client.uid,"message","("..command.description..")")
			 	--	net_send(client.uid,"message"," ")
			 --	end
			-- end
			{'Insert instructions here','Insert instructions here'},
			{'Insert instructions here','Insert instructions here'},
			{'Insert instructions here','Insert instructions here'},
		}
	},
	{menu="Commands",icon="icon-admin",
		{title="Commands",
			{'Insert command here','Insert command here'},

		}
	}
}
local function help(client)
	local subhelp={}
	local help=""
	
	for i,a in ipairs(layout)do
		help=help..[[<tr><td align='center'><input type='button'class='ibutton1'value=']]..a.menu..[['onclick='/help ]]..i..[['icon=']]..a.icon..[['/>]]
		local H=''
		for _,b in ipairs(a)do
			H=H..[[<tr><td align='left'><table class='header'><tr><td><p>]]..b.title..[[</p></table><tr><td><table class='box'width='285px'>]]
			for _,v in ipairs(b)do
				H=H..[[<tr><td width='120px'>]]..v[1]..[[<td width='165px'>]]..v[2]..(_==#b and''or[[<tr><td>]])
			end
			H=H..[[</table><tr><td>]]
		end
		subhelp["help "..i]=H..[[<tr><td align='center'><input type='button'class='ibutton1'value='Back'onclick='/help'icon='icon-restart'/>]]
	end
	
	help=help..[[<tr><td align='center'><input type='button'class='ibutton1'value='Back'onclick='/players'icon='icon-restart'/>]]

	subhelp["help"]=help
	return subhelp[client.window]

end

-- Generate playerlist --
local function playerlist(client)
	local substitute=function(s,t)return s:gsub('$(%w+)',function(i)return t[i]or''end)end
	local list={}
	for _,v in pairs(GAME.clients)do
		list[#list+1]=v
	end
	local k=true
	repeat
		k=true
		for i=1,#list-1 do
			local a,b=list[i],list[i+1]
			if not a or not b then break end
			local swap=false
			if(a.approved == b.approved) then
			if a.status==b.status then
				if a.wins==b.wins then
					if(b.adminLevel)<(a.adminLevel)then
						swap=true
					end
				elseif(b.wins)>(a.wins)then
					swap=true
				end
				
				if GAME.settings.numteams>0 then
					if(GAME.settings.teams[a.name]or 0)<(GAME.settings.teams[b.name]or 0)then
						swap=false
					elseif(GAME.settings.teams[a.name]or 0)>(GAME.settings.teams[b.name]or 0)then
						swap=true
					end
				end
				
			elseif b.status=='play'and a.status~='play'then
				swap=true
			elseif b.status=='queue'and a.status=='away'then
				swap=true
			elseif a.status == 'afk' then
				swap = true
			end
			else
				if(b.approved == true and a.approved == false) then
					swap = true
				end
			end
			if swap then
				list[i+1]=a
				list[i]=b
				k=false
			end
		end
		--[[
			<input type='button'width=$width height=40  onclick=''class='icon1'>
					<rank value='$rank'width=$rw height=$rh>
				</input>
				
			<td width=$width>
			
						<td width=16><img src='cuzco'width=34 height=34/>

			
				--]]
	until k
	local player=[[<tr><td align=left>
		<table background='white:$color'><tr>
			$approve
			$rankbox
			$teambox
			<td width=2>
				<img src='blank'width=2 height=5>
			<td width='$approvew'align=left clip=1>
				<div font='font-outline:18'color='$color2'>
					$name<br/>[$statusTxt]
				</div>
			<td width=1>
				<img src='blank'width=1 height=5>
			<td width=25 background='white:$woncolor'clip=1>
				<div font='font-outline:18'>$wins</div>
			<td width=2>
				<img src='blank'width=2 height=5>
			<td width=$width height=40><p>&nbsp;</p>
			<td width=$width height=40>
				<input type='button'width=$width height=40 class='icon1'onclick='*status	'>
					<img src='$icon'width=24 height=24/>
				</input>
		</table>]]
		
	local players=''
	for _=1,#list do
		local v=list[_]
		local shrink=GAME.settings.approval and GAME.settings.numteams>1 and GAME.settings.teamsedit and (client.adminLevel >= 2)
		local width=shrink and 32 or 40
		players=players..substitute(player,{
			color='#'..hex(v.color,-.5);
			color2='#'..(fixcolor[v.color]or hex(v.color));
			woncolor='#'..(GAME.game.won[v.name]and hex(v.color,.5)or hex(v.color,-.5));
			statusTxt=''..v.statusTxt;

			width=width;
			approvew=GAME.settings.numteams>1 and(GAME.settings.approval and((client.adminLevel >= 2) and(GAME.settings.teamsedit and 95 or 70)or 115)or GAME.settings.teamsedit and (client.adminLevel >= 2) and 95 or 110)or GAME.settings.approval and((client.adminLevel >= 2)and 95 or 115)or 135;
			approve=(GAME.settings.approval and[[
					<td width=]]..((client.adminLevel >= 2) and width or 20)..[[>
						<input type='button'width=]]..((client.adminLevel >= 2)and width or 20)..[[ height=40 onclick=']]..(((v.approved == true))and'/unapprove 'or'/approve ')..v.name..[['class=']]..((client.adminLevel >= 2)and'icon2'or'none')..[['>
							<img width=24 height=24 src='icon-]]..((v.approved == true or (v.adminLevel >= 2))and'play'or'disabled')..[['/>
						</input>
			]]or'');
			rank=getrank(v);
			rw=shrink and 24 or 30;
			rh=shrink and 16 or 20;
			name=nameStr(v);
			wins=v.wins;
		
			icon='icon-'..(v.adminLevel == 2 and'admin-alt2'or (v.adminLevel >= 2) and'admin'or v.status);
			rankbox = v.goat == false and substitute([[
			<td width=$width>
			<input type='button'width=$width height=40  onclick=''class='icon1'>
					<rank value='$rank'width=$rw height=$rh>
				</input>
				
			]],{rank=getrank(v);width = width;rw = shrink and 24 or 30; rh = shrink and 16 or 20}) 
			or substitute([[<td width=40 height=40><img src='cuzco'width=40 height=40/>]],
			{});
			teambox=GAME.settings.numteams>0 and substitute([[
			<td width=$width height=40 background='white:$tcolor'>]]..(GAME.settings.teamsedit and (client.adminLevel >= 2)and[[
				<input type='button'width=$width heigh=40 onclick='/swap ]]..v.name..[['class='icon1'>]]or'')..[[
				<div font='font-outline:18'>$team</div>]],{
				team=GAME.settings.teams[v.name]and"T"..GAME.settings.teams[v.name]or'';
				tcolor=GAME.settings.teams[v.name]and(v.status=="play"and({"#3636bf","#bf1e1e","#bfbf1e","#1ebfbf","#1ebf1e","#bf1ebf"})[GAME.settings.teams[v.name]]or"#555555")or'#2b2b2b';
				width=GAME.settings.teamsedit and (client.adminLevel >= 2)and width or 25}
			)or''
		})
	end

	return[[<tr><td><table class='box'>]]..players..[[</table>]]
end



-- Main HTML --
local function lobby(client)

	local t={
		space='<tr><td><h4>&nbsp;</h4>';
	}
	local substitute=function(s,T)T=T or t
		return s:gsub('$(%w+)',function(i)return T[i]or''end)
	end
	
	t.teams=GAME.settings.numteams>1 and substitute[[
	<tr><td align=left>Teams:
		<td align=left>$numteams
	]]or''
	
	t.edit=GAME.settings.numteams>1 and GAME.settings.teamsedit and[[
	<tr><td align=left>Edit teams:
		<td align=left>Enabled]]or''
		
	t.topic = substitute[[
			<tr><td align=center>
			<h4 class='box2'width=240 align='center'>]]..GAME.settings.topic..[[</h4>
			<tr>
			<tr><td align=center>
			<tr>

	]]
	if(GAME.settings.topic == "") then
		t.topic = ""
	end

	t.settings=substitute[[
			
			<td>
		
			
				<table width=240 class=box2 align=center>
					<tr><td align=left>Mode:
						<td align=left>]]..GAME.mode.current..[[
				</table>]]
	if(client.status=="play"and not GAME.settings.strict) or client.adminLevel >= 2 then
		t.startbox=[[<tr><td align=center>
			<input type='button'onclick='/start'class='toggle1'icon='icon-queue'width=100>
				<table><tr>
					<td width=16><img src='icon-play'width=16 height=16/>
					<td width=65><h4>Start</h4>
				</table>
			</input>]]
	elseif GAME.settings.strict then
		t.startbox=[[<tr><td align=center>
			<h4 class='box2'width=240 align='center'>Start only available to admins.</h4>]]
	else
		t.startbox=[[<tr><td align=center>
			<h4 class='box2'width=240 align='center'>Start only available to players.</h4>]]
	end
	--local screen=math.max(GAME.sw,GAME.sh)
	--if screen<=600 then
		--t.device='icon-phone'
	--elseif screen<=900 then
		t.device='icon-standard'
	--else
		t.device='icon-desktop'
	--end
	t.modebar=substitute[[
	<tr><td align=left>
		<table class='header'><tr>
			<td><img src='$device'width=18 height=18/>
			<td>&nbsp;
			<td><h3>$mode &nbsp;</h3>
			<td><img src='icon-admin'width=18 height=18/>
			<td>&nbsp;
			<td><h3>]]..GAME.config.roomName..[[</h3>
		</table>]]
	t.playerlist=playerlist(client)
	return substitute[[
		$topic
		$settings
		$space
		$startbox
		$space
		$modebar
		$playerlist
	]]
end

local q=''
local q1=''
do
	local t={'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z','a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z','0','1','2','3','4','5','6','7','8','9','+','/'}
	local filled={'V','W','X','Z','a','b','l','m','n','p','q','r','1','2','3','9','+','/'}
	for i=1,1 do
		q=q..filled[math.random(1,#filled)]
	end
	local o={math.random(1,64),math.random(1,16),math.random(1,64),math.ceil(math.random(1,64)/4)*4-3}
	q1=t[o[1]]..t[o[2]]..t[o[3]]..t[o[4]]
	local c64={red='110000',green='001100',blue='000011',cyan='001111',magenta='110011',yellow='110000',white='111111',black='000000',orange='111000',purple='100011'}
	local col=c64.red..'00'..c64.red..'00'..c64.green..'10'
	local tc={col:sub(1,6),col:sub(7,12),col:sub(13,18),col:sub(19,24)}
	for _,v in ipairs(tc)do
		local n=1
		for i=1,#v do
			if v:sub(i,i)=='1'then
				n=n+2^(#v-i)
			end
		end
		tc[_]=t[n]
	end
	q1=tc[1]..tc[2]..tc[3]..tc[4]
	
end
local function pixart()
	return[[
	<tr><td><table><tr><td><br/><tr>
		<td>
			<pixart name='icon'edit=1 data='AQ4OBAA]]..q1..'Var/1Vqv/VWq/9Var/1Vqv/VWq/9Var/1Vqv/VWq/9Var/1Vqv/VWq/9Var/1Vqv/'..[[' width=160 height=200/>
	</table>]]
end

-- Send HTML --
function HTML(client)

	local t={
		space='<tr><td><h4>&nbsp;</h4>';
		plist=playerlist(client);
		play='ibutton'..(client.status=='play'and'2'or'1');
		queue='ibutton'..(client.status=='queue'and'2'or'1');
		away='ibutton'..(client.status=='away'and'2'or'1');
		status=client.status
	}
	
	local substitute=function(s)
		return s:gsub('$(%w+)',function(i)return t[i]or''end)
	end
	local uid=client.uid
	if g2.state=="lobby"then
		net_send(uid,"html",'<table>'..(client.window:sub(1,4)=='help' and help(client) or lobby(client))..'</table>')
		net_send(uid,"tabs",tabs(client))
	else
	--[=[
		local window=[[<table>
			<tr><td align=center><input type='button'class='ibutton1'value='Resume'onclick='resume'icon='icon-resume'/>
			<tr><td align=center><input type='button'class='ibutton1'value='Surrender'onclick='/surrender'icon='icon-surrender'/>
			<tr><td align=center><input type='button'class='ibutton1'value='Players'onclick='*players	'icon='icon-players'/>
			<tr><td align='center'><input type='button'class='ibutton1'value='Status'onclick='*statuswindow	'icon='icon-$status'/>
			<tr><td align='center'><input type='button'class='ibutton1'value='Leave'onclick='leave'icon='icon-leave'/>
		</table>]]
		local list=[[<table>$plist$space<tr><td align=center><input type='button'class='ibutton1'value='Back'onclick='*players	'icon='icon-restart'/>]]
		local statuswindow=[[<table><tr><td align=center><h2>Your Status</h2>$space
		<tr><td align=center><input type='button'class='$play'value='Play'onclick='*status	play'icon='icon-play'/>
		<tr><td align=center><input type='button'class='$queue'value='Queue'onclick='*status	play'icon='icon-queue'/>
		<tr><td align=center><input type='button'class='$away'value='Away'onclick='*status	away'icon='icon-away'/>
		<tr><td align=center><input type='button'class='ibutton1'value='Back'onclick='*statuswindow	'icon='icon-restart'/>
		</table>]]
		if client.window=='players'then
			window=list
		elseif client.window=='status'then
			window=statuswindow
		end
		net_send(uid,"html",substitute(window))
		]=]
	end
	
	
end