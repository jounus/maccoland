local function getrank(v) -- Determine user rank icon hex
	local mwins,mplays,mrat=0,0,0
	for _,v in pairs(GAME.clients)do
		local name=v.name
		if GAME.plays[name]then
			mplays=math.max(mplays,math.sqrt(GAME.plays[name]))
			if GAME.wins[name]then
				mwins=math.max(mwins,math.sqrt(GAME.wins[name]))
				mrat=math.max(mrat,GAME.wins[name]/(GAME.plays[name]+1))
			end
		end
	end
	local rank={'1','2','3','4','5','6','7','8','9','a'}
	local flag=rank[mwins==0 and 1 or math.floor(math.sqrt(GAME.wins[v.name]or 0)*9/mwins)+1]
	local star=rank[mplays==0 and 1 or math.floor(math.sqrt(GAME.plays[v.name]or 0)*9/mplays)+1]
	local r1=(GAME.wins[v.name]or 0)/((GAME.plays[v.name]or 1)+1)
	local r2=mrat==0 and 1 or mrat
	local wing=rank[math.max(1,math.min(10,math.floor(r1*9/r2)+1))]
	return flag..star..wing
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
		title =GAME.title;
	})[i]or''end)end
	return substitute[[<table><tr>
		<td><input width='20%'type='button' disabled='true'pseudo='first'class='tab'/>
		<td><input width='20%'type='button' onclick ='*lobby	'value='Lobby'icon='icon-lobby'class='$lobby'/>
		<td><input width='20%'type='button' onclick ='*status	'value='Status'icon='icon-$status'class='tab'>
		<td><input width='20%'type='button' onclick =''    value='$title'icon='icon-galaxy'class='tab'/>
		<td><input width='20%'type='button' onclick ='*help	'value='Help'icon='icon-help'pseudo='last'class='$help'>
	</table>]]
end

-- Help HTML --
local clist={'random'}
for _,v in pairs(colorset)do
	clist[#clist+1]=_
end
local layout={
	{menu="Instructions",icon="icon-member",
		{title="User Commands",
			{'/start','Begins the game when strict is not enabled'},
			{'/surrender','Neutralizes all of your planets'},
			{'/color COLOR','Sets your preferred color. Only one user per color.'},
			{'COLORS:',table.concat(clist,", ")}
		}
	},
	{menu="Commands",icon="icon-admin",
		{title="Admin Commands",
			{'/start','Begins the game'},
			{'/abort','Ends the game'},
			{'/strict','When enabled, non-GAME.admins cannot /start.'},
			{'/approval','When enabled, only approved players and admins can be /play.'},
			{'/play username','Sets a user to play'},
			{'/away username','Sets a user away'}
		},{title="Settings",
			{'/mode mode','Modes: FFA, Frenzy, Collide'},
			{'/crash','Toggle crash mode'},
			{'/neut #','Sets the number of neutrals'},
			{'/cost a b','Sets the cost of neutrals to a range from a to b (or just a)'},
			{'/prod a b','Sets the prod of neutrals to a range from a to b (or just a)'},
			{'/home #','Sets the production of the home planet'},
			{'/ships #','Sets the initial number of ships in the home planet'},
			{'/width #','Sets the width of the map'},
			{'/height #','Sets the height of the map'},
			{'/square #','Sets the width and height of the map'}
		},{title="Presets",
			{'/waffle','50 free neutrals, start with 0 ships.'},
			{'/standard','Default settings preset'},
			{'/medium','Medium standard preset'},
			{'/large','Large standard preset'}
		},{title="Bots",
			{'/bot type name','Adds a new bot with type "type" and name "name"'},
			{'/remove name','Removes the bot "name"'}
		}
	}
}
local function help(client)
	local subhelp={}
	local help=""
	
	for i,a in ipairs(layout)do
		help=help..[[<tr><td align='center'><input type='button'class='ibutton1'value=']]..a.menu..[['onclick='*help	]]..i..[['icon=']]..a.icon..[['/>]]
		local H=''
		for _,b in ipairs(a)do
			H=H..[[<tr><td align='left'><table class='header'><tr><td><p>]]..b.title..[[</p></table><tr><td><table class='box'width='285px'>]]
			for _,v in ipairs(b)do
				H=H..[[<tr><td width='120px'>]]..v[1]..[[<td width='165px'>]]..v[2]..(_==#b and''or[[<tr><td>]])
			end
			H=H..[[</table><tr><td>]]
		end
		subhelp["help	"..i]=H..[[<tr><td align='center'><input type='button'class='ibutton1'value='Back'onclick='*help	'icon='icon-restart'/>]]
	end
	
	help=help..[[<tr><td align='center'><input type='button'class='ibutton1'value='Back'onclick='*players	'icon='icon-restart'/>]]
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
			if a.status==b.status then
				if a.wins==b.wins then
					if(b.adminLevel or 3)<(a.adminLevel or 3)then
						swap=true
					end
				elseif(b.wins or 0)>(a.wins or 0)then
					swap=true
				end
				--[[
				if GAME.numteams>0 then
					if(GAME.teams[a.name]or 0)<(GAME.teams[b.name]or 0)then
						swap=false
					elseif(GAME.teams[a.name]or 0)>(GAME.teams[b.name]or 0)then
						swap=true
					end
				end
				--]]
			elseif b.status=='play'and a.status~='play'then
				swap=true
			elseif b.status=='queue'and a.status=='away'then
				swap=true
			end
			if swap then
				list[i+1]=a
				list[i]=b
				k=false
			end
		end
	until k
	local player=[[<tr><td align=left>
		<table background='white:$color'><tr>
			$approve
			<td width=$width>
				<input type='button'width=$width height=40 onclick=''class='icon1'>
					<rank value='$rank'width=$rw height=$rh>
				</input>
			$teambox
			<td width=2>
				<img src='blank'width=2 height=5>
			<td width='$approvew'align=left clip=1>
				<div font='font-outline:18'color='$color2'>
					$name<br/>[Waffles]
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
		
		--[=[
	local players=''
	for _=1,#list do
		local v=list[_]
		local shrink=GAME.approval and GAME.numteams>1 and GAME.teamsedit and GAME.admins[client.name]
		local width=shrink and 32 or 40
		players=players..substitute(player,{
			color='#'..hex(v.color,-.5);
			color2='#'..(fixcolor[v.color]or hex(v.color));
			woncolor='#'..(GAME.game.won[v.name]and hex(v.color,.5)or hex(v.color,-.5));
			width=width;
			approvew=GAME.numteams>1 and(GAME.approval and((client.adminLevel >= 2) and(GAME.teamsedit and 95 or 70)or 115)or GAME.teamsedit and (client.adminLevel >= 2) and 95 or 110)or GAME.approval and(client.adminLevel >= 2)and 95 or 115)or 135;
			approve=(GAME.approval and[[
					<td width=]]..((client.adminLevel >= 2) and width or 20)..[[>
						<input type='button'width=]]..(GAME.admins[client.name]and width or 20)..[[ height=40 onclick=']]..((GAME.approved[v.name]or GAME.admins[v.name])and'/unapprove 'or'/approve ')..v.name..[['class=']]..(GAME.admins[client.name]and'icon2'or'none')..[['>
							<img width=24 height=24 src='icon-]]..((GAME.approved[v.name]or GAME.admins[v.name])and'play'or'disabled')..[['/>
						</input>
			]]or'');
			rank=getrank(v);
			rw=shrink and 24 or 30;
			rh=shrink and 16 or 20;
			name=v.name;
			wins=v.wins or 0;
			icon='icon-'..(GAME.admins[v.name]==1 and'admin-alt2'or (v.adminLevel >= 2) and'admin'or v.status);
			teambox=GAME.numteams>0 and substitute([[
			<td width=$width height=40 background='white:$tcolor'>]]..(GAME.teamsedit and GAME.admins[client.name]and[[
				<input type='button'width=$width heigh=40 onclick='/swap ]]..v.name..[['class='icon1'>]]or'')..[[
				<div font='font-outline:18'>$team</div>]],{
				team=GAME.teams[v.name]and"T"..GAME.teams[v.name]or'';
				tcolor=GAME.teams[v.name]and(v.status=="play"and({"#3636bf","#bf1e1e","#bfbf1e","#1ebfbf","#1ebf1e","#bf1ebf"})[GAME.teams[v.name]]or"#555555")or'#2b2b2b';
				width=GAME.teamsedit and GAME.admins[client.name]and width or 25}
			)or''
		})
	end
	
	return[[<tr><td><table class='box'>]]..players..[[</table>]]
	--]=]
end

-- Main HTML --
local function lobby(client)
return ""
--[=[
	local t={
		space='<tr><td><h4>&nbsp;</h4>';
	}
	local substitute=function(s,T)T=T or t
		return s:gsub('$(%w+)',function(i)return T[i]or''end)
	end
	t.teams=GAME.numteams>1 and substitute[[
	<tr><td align=left>Teams:
		<td align=left>$numteams
	]]or''
	t.edit=GAME.numteams>1 and GAME.teamsedit and[[
	<tr><td align=left>Edit teams:
		<td align=left>Enabled]]or''
	t.crash=GAME.crash and[[
	<tr><td align=left>Fleet:
		<td align=left>Crash
	]]or''
	t.incognito=GAME.incognito and[[
	<tr><td align=left>Incognito:
		<td align=left>on
	]]or''
	t.revolts=GAME.revolts and[[
	<tr><td align=left>Revolts:
		<td align=left>on
	]]or''
	t.velocity=GAME.velocity==1 and''or substitute[[
		<tr><td align=left>Ships speed:
			<td align=left>$vel
	]]
	t.visible=GAME.visible and[[
		<tr><td align=left>Visible ships:
			<td align=left>on]]or''
	t.strict=GAME.strict and([[
		<tr><td align=left>Strict:
			<td align=left>on]])or''
	t.symmetric=GAME.symmetric and''or[[
		<tr><td align=left>Symmetry:
			<td align=left>off]]
	t.settings=substitute[[
		<tr>
			<td>
				<table width=240 class=box2 align=center>
					<tr><td align=left>Mode:
						<td align=left>$mode
					$teams
					$edit
					$crash
					$incognito
					$revolts
					<tr><td align=left>Neutrals: 
						<td align=left>$neutrals
					<tr><td align=left>Size:
						<td align=left>$map
					<tr><td align=left>Start ships:
						<td align=left>$ships
					<tr><td align=left>Production:
						<td align=left>$home
					<tr><td align=left>Neutral cost:
						<td align=left>$cost
					<tr><td align=left>Neutral prod:
						<td align=left>$prod
					$velocity
					$visible
					$strict
					$symmetric
				</table>]]
	if(client.status=="play"and not GAME.strict)or GAME.admins[client.name]then
		t.startbox=[[<tr><td align=center>
			<input type='button'onclick='/start'class='toggle1'icon='icon-queue'width=100>
				<table><tr>
					<td width=16><img src='icon-play'width=16 height=16/>
					<td width=65><h4>Start</h4>
				</table>
			</input>]]
	elseif GAME.strict then
		t.startbox=[[<tr><td align=center>
			<h4 class='box2'width=240 align='center'>Start only available to admins.</h4>]]
	else
		t.startbox=[[<tr><td align=center>
			<h4 class='box2'width=240 align='center'>Start only available to players.</h4>]]
	end
	local screen=math.max(GAME.sw,GAME.sh)
	if screen<=600 then
		t.device='icon-phone'
	elseif screen<=900 then
		t.device='icon-standard'
	else
		t.device='icon-desktop'
	end
	t.modebar=substitute[[
	<tr><td align=left>
		<table class='header'><tr>
			<td><img src='$device'width=18 height=18/>
			<td>&nbsp;
			<td><h3>$mode &nbsp;</h3>
			<td><img src='icon-admin'width=18 height=18/>
			<td>&nbsp;
			<td><h3>waffle3z</h3>
		</table>]]
	t.playerlist=playerlist(client)
	return substitute[[
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
	--]=]
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
		net_send(uid,"html",'<table>'..help(client)..'</table>')
		--net_send(uid,"html",'<table>'..(client.window:sub(1,5)=='help'and help(client)or lobby(client))..'</table>')
	--	net_send(uid,"tabs",tabs(client))
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