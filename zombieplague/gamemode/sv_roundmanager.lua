CreateConVar("zp_min_players", 2, 8, "cvar used to define minimun players to start the round.")
CreateConVar("zp_newround_delay", 10, 8, "cvar used to define new round time delay.")
CreateConVar("zp_infection_delay", 10, 8, "cvar used to define infection time delay.")
CreateConVar("zp_max_rounds", 10, 8, "cvar used to define the total of rounds.")
CreateConVar("zp_round_time", 300, 8, "cvar used to define round time")

RoundManager = {RoundState = 0, Round = 0, Rounds = {}, PlayersToPlay = {}, Deathmatch = false}
function RoundManager:SearchRounds()
	RoundManager:AddRoundType({})

	local Files = file.Find("zombieplague/gamemode/rounds/*.lua", "LUA")
	if Files != nil then
		for k, File in pairs(Files) do
			include("zombieplague/gamemode/rounds/" .. File)
		end
	end
end
function RoundManager:AddRoundType(RoundType)
	table.insert(RoundManager.Rounds, {Name = RoundType.Name or "Simple infection Mode",
		Chance = RoundType.Chance or 100,
		MinPlayers = RoundType.MinPlayers or cvars.Number("zp_min_players", 2),
		SpecialRound = RoundType.SpecialRound or false,
		Deathmatch = RoundType.Deathmatch or false,
		StartSound = RoundType.StartSound,
		StartFunction = RoundType.StartFunction or function()
			local FirstZombie = table.Random(RoundManager:GetPlayersToPlay(true))
			FirstZombie:Infect()
			for k, ply in pairs(player.GetAll()) do
				SendNotifyMessage(ply, Dictionary:GetPhrase("RoundSimple", ply), 5, Color(0, 255, 0))
				SendPopupMessage(ply, string.format(Dictionary:GetPhrase("NoticeFirstZombie", ply), FirstZombie:Name()))
			end
		end})
		if RoundType.StartSound != nil then
			for k, SoundPath in pairs(RoundType.StartSound) do
				resource.AddFile("sound/" .. SoundPath)
			end
		end
end
function RoundManager:GetServerStatus()
	local ServerStatus = {Timer = RoundManager:GetTime(),
		RoundState = RoundManager:GetRoundState(),
		Round = RoundManager:GetRound(),
		Players = {}}

	for k, ply in pairs(RoundManager:GetPlayersToPlay()) do
		table.insert(ServerStatus.Players, {SteamID = ply:SteamID(),
			AmmoPacks = ply:GetAmmoPacks(),
			Battery = ply:GetMaxBatteryCharge(),
			ZombieClass = ply:GetZombieClass().Name,
			HumanClass = ply:GetHumanClass().Name,
			Light = ply:GetLight()
		})
	end

	return ServerStatus
end
function RoundManager:SetTimer(Time, TimeFunction)
	timer.Destroy("ZombiePlagueTimer")
	timer.Create("ZombiePlagueTimer", Time, 1, TimeFunction)
	net.Start("SyncTimer")
		net.WriteInt(Time, 16)
	net.Broadcast()
end
function RoundManager:GetTime()
	return timer.TimeLeft("ZombiePlagueTimer") or 0
end
function RoundManager:SetRoundState(RoundState)
	RoundManager.RoundState = RoundState
	net.Start("SendRoundState")
		net.WriteInt(RoundState, 4)
	net.Broadcast()

	hook.Call("ZPSetRoundState", GAMEMODE, RoundState)
end
function RoundManager:GetRoundState()
	return RoundManager.RoundState
end
function RoundManager:SetSpecialRound(SpecialRound)
	RoundManager.SpecialRound = SpecialRound
end
function RoundManager:IsSpecialRound()
	return RoundManager.SpecialRound or false
end
function RoundManager:SetDeathmatch(Deathmatch)
	RoundManager.Deathmatch = Deathmatch
end
function RoundManager:IsDeathMatch()
	return RoundManager.Deathmatch
end
function RoundManager:CheckRoundEnd()
	if RoundManager:GetRoundState() == ROUND_PLAYING then
		if RoundManager:CountHumansAlive() == 0 then
			RoundManager:EndRound(ZOMBIES_WIN)
		elseif RoundManager:CountZombiesAlive() == 0 then
			RoundManager:EndRound(HUMANS_WIN)
		end
	end
end
function RoundManager:WaitPlayers()
	timer.Destroy("ZombiePlagueTimer")
	RoundManager:SetRoundState(ROUND_WAITING_PLAYERS)
end
function RoundManager:Prepare()
	if RoundManager:CountPlayersToPlay() >= cvars.Number("zp_min_players",  2) then
		hook.Call("ZPPrePreparingRound")
		game.CleanUpMap()
		RoundManager:SetRoundState(ROUND_STARTING_NEW_ROUND)
		for k, ply in pairs(RoundManager:GetPlayersToPlay()) do
			ply:SetNemesis(false)
			ply:SetSurvivor(false)
			ply:SetLight(nil)
			ply:ResetZombieAllowedWeapons()
			ply:SetTeam(TEAM_HUMANS)
			ply:Spawn()
		end
		hook.Call("ZPPostPreparingRound")
		return true
	else
		return false
	end
end
function RoundManager:TryNewRound()
	if RoundManager:Prepare() then
		RoundManager:SetTimer(cvars.Number("zp_infection_delay",  10), RoundManager.NewRound)
	else
		RoundManager:WaitPlayers()
	end
end
function RoundManager:NewRound()
	local TotalChance = 0
	local ValidRounds = {}
	local TotalPlayers = RoundManager:CountPlayersToPlay(true)
	for k, Round in pairs(RoundManager:GetRounds()) do
		if TotalPlayers >= Round.MinPlayers then
			TotalChance = TotalChance + Round.Chance
			table.insert(ValidRounds, Round)
		end
	end
	if TotalChance > 0 then
		local Floor = 1
		local Dice = math.random(Floor, TotalChance)

		for k, Round in pairs(ValidRounds) do
			Floor = Floor + Round.Chance
			if Dice < Floor then
				RoundManager:StartRound(Round)
				break
			end
		end
	else
		RoundManager:TryNewRound()
	end
end
function RoundManager:RestartRound()
	RoundManager:SetTimer(cvars.Number("zp_newround_delay",  10), RoundManager.TryNewRound)
	RoundManager:SetRoundState(ROUND_RESTARTING)

	hook.Call("ZPRestartRound")
end
function RoundManager:EndRound(Reason)
	net.Start("SendRoundEnd")
		net.WriteInt(Reason, 4)
	net.Broadcast()

	if Reason == ZOMBIES_WIN then
		for k, ply in pairs(player.GetAll()) do
			SendNotifyMessage(ply, Dictionary:GetPhrase("ZombiesWin", ply), 5, Color(0, 255, 0))
		end
		BroadcastSound(SafeTableRandom(ZombieWinSounds))
	elseif Reason == HUMANS_WIN then
		for k, ply in pairs(player.GetAll()) do
			SendNotifyMessage(ply, Dictionary:GetPhrase("HumansWin", ply), 5, Color(0, 255, 0))
		end
		BroadcastSound(SafeTableRandom(HumanWinSounds))
	else
		for k, ply in pairs(player.GetAll()) do
			SendNotifyMessage(ply, Dictionary:GetPhrase("RoundDraw", ply), 5, Color(0, 255, 0))
		end
	end

	if RoundManager:GetRound() < cvars.Number("zp_max_rounds", 10) then
		RoundManager:SetRoundState(ROUND_ENDING)
		RoundManager:SetTimer(cvars.Number("zp_newround_delay",  10), RoundManager.TryNewRound)
	else
		ZPVoteMap:StartVotemap(ALLOWED_PREFIX)
	end
	hook.Call("ZPEndRound", GAMEMODE, Reason)
end
function RoundManager:StartRound(RoundToStart)
	RoundToStart.StartFunction()
	RoundManager:SetSpecialRound(RoundToStart.SpecialRound)
	RoundManager:SetDeathmatch(RoundToStart.Deathmatch)
	if RoundToStart.StartSound != nil then
		BroadcastSound(SafeTableRandom(RoundToStart.StartSound))
	end

	RoundManager:SetTimer(cvars.Number("zp_round_time", 300), function()
		RoundManager:EndRound(ROUND_DRAW)
	end)

	RoundManager.Round = RoundManager.Round + 1
	net.Start("SendRound")
		net.WriteInt(RoundManager.Round, 8)
	net.Broadcast()

	RoundManager:SetRoundState(ROUND_PLAYING)

	hook.Call("ZPNewRound", GAMEMODE, RoundManager:GetRound())
end
function RoundManager:GetGoodRounds()
	local GoodRounds = {}
	local TotalPlayers = RoundManager:CountPlayerToPlayAlive()
	for k, Round in pairs(RoundManager:GetRounds()) do
		if TotalPlayers >= Round.MinPlayers then
			table.insert(GoodRounds, Round)
		end
	end

	return GoodRounds
end
function RoundManager:GetGoodRoundsName()
	local GoodRounds = {}
	local TotalPlayers = RoundManager:CountPlayerToPlayAlive()
	for k, Round in pairs(RoundManager:GetRounds()) do
		if TotalPlayers >= Round.MinPlayers then
			table.insert(GoodRounds, Round.Name)
		end
	end

	return GoodRounds
end
function RoundManager:GetRound()
	return RoundManager.Round
end
function RoundManager:IsRealisticMod()
	return cvars.Bool("zp_realistic_mode", false)
end
function RoundManager:GetRounds()
	return RoundManager.Rounds
end
function RoundManager:ShouldRoundEnd()
	return RoundManager:CountHumansAlive() == 0 || RoundManager:CountZombiesAlive() == 0
end
function RoundManager:OpenRoundsMenu(ply)
	net.Start("OpenBackMenu")
		net.WriteString("SendRounds")
		net.WriteTable(RoundManager:GetGoodRoundsName())
	net.Send(ply)
end
function RoundManager:LastHuman()
	local i = 0
	for k, ply in pairs(team.GetPlayers(TEAM_HUMANS)) do
		if ply:Alive() then
			i = i + 1
			if i > 1 then
				return false
			end
		end
	end
	return i == 1
end
function RoundManager:LastZombie()
	local i = 0
	for k, ply in pairs(team.GetPlayers(TEAM_ZOMBIES)) do
		if ply:Alive() then
			i = i + 1
			if i > 1 then
				return false
			end
		end
	end
	return i == 1
end
function RoundManager:CountHumansAlive()
	local i = 0
	for k, ply in pairs(team.GetPlayers(TEAM_HUMANS)) do
		if ply:Alive() then
			i = i + 1
		end
	end
	return i
end
function RoundManager:CountZombiesAlive()
	local i = 0
	for k, ply in pairs(team.GetPlayers(TEAM_ZOMBIES)) do
		if ply:Alive() then
			i = i + 1
		end
	end
	return i
end
function RoundManager:AddPlayerToPlay(ply)
	table.insert(RoundManager.PlayersToPlay, ply)
	ply:SetTeam(TEAM_HUMANS)

	if RoundManager:GetRoundState() == ROUND_WAITING_PLAYERS && RoundManager:CountPlayersToPlay() >= cvars.Number("zp_min_players", 2) then
		RoundManager:RestartRound()
	end
end
function RoundManager:RemovePlayerToPlay(ply)
	ply:SetTeam(TEAM_SPECTATOR)
	table.RemoveByValue(RoundManager.PlayersToPlay, ply)

	if ply:IsZombie() && RoundManager:CountZombiesAlive() == 0 && RoundManager:CountHumansAlive() > 1 then
		local NewZombie = SafeTableRandom(RoundManager:GetAliveHumans())
		NewZombie:Infect()

		for k, ply in pairs(player.GetAll()) do
			SendPopupMessage(ply, string.format(Dictionary:GetPhrase("LastZombieLeft", ply), NewZombie:Name()))
		end
	elseif ply:IsHuman() && RoundManager:CountHumansAlive() == 0 && RoundManager:CountZombiesAlive() > 1 then
		local NewHuman = SafeTableRandom(RoundManager:GetAliveZombies())
		NewHuman:Cure()

		for k, ply in pairs(player.GetAll()) do
			SendPopupMessage(ply, string.format(Dictionary:GetPhrase("LastHumanLeft", ply), NewHuman:Name()))
		end
	end

	RoundManager:CheckRoundEnd()
end
function RoundManager:CountPlayersToPlay(Alive)
	if !Alive then
		return table.Count(RoundManager:GetPlayersToPlay())
	end
	
	local i = 0
	for k, ply in pairs(RoundManager:GetPlayersToPlay(true)) do
		i = i + 1
	end

	return i
end
function RoundManager:GetPlayersToPlay(Alive)
	if !Alive then
		return RoundManager.PlayersToPlay or {}
	end
	
	local Alive = {}
	for k, ply in pairs(RoundManager.PlayersToPlay) do
		if ply:Alive() then
			table.insert(Alive, ply)
		end
	end

	return Alive
end
function RoundManager:GetAliveHumans()
	local AliveHumans = {}
	for k, ply in pairs(team.GetPlayers(TEAM_HUMANS)) do
		if ply:Alive() then
			table.insert(AliveHumans, ply)
		end
	end
	return AliveHumans
end
function RoundManager:GetAliveZombies()
	local AliveZombies = {}
	for k, ply in pairs(team.GetPlayers(TEAM_ZOMBIES)) do
		if ply:Alive() then
			table.insert(AliveZombies, ply)
		end
	end
	return AliveZombies
end
hook.Add("PostPlayerDeath", "RoundEndCheck", function()
	RoundManager:CheckRoundEnd()
end)

net.Receive("SendRounds", function(len, ply)
	if (ply:IsAdmin() || ply:IsSuperAdmin()) && RoundManager:GetRoundState() == ROUND_STARTING_NEW_ROUND then
		local Round = RoundManager:GetGoodRounds()[net.ReadInt(16)]
		RoundManager:StartRound(Round)
		for k, Play in pairs(player.GetAll()) do
			SendPopupMessage(Play, string.format(Dictionary:GetPhrase("NoticeForceRound", Play), ply:Name(), Round.Name))
		end
	else
		SendPopupMessage(ply, Dictionary:GetPhrase("NoticeNotAllowed", ply))
	end
end)
net.Receive("RequestRoundMenu", function(len, ply)
	if ply:IsAdmin() || ply:IsSuperAdmin() then
		RoundManager:OpenRoundsMenu(ply)
	else
		SendPopupMessage(ply, Dictionary:GetPhrase("NoticeNotAllowed", ply))
	end
end)

util.AddNetworkString("SyncTimer")
util.AddNetworkString("SendRoundState")
util.AddNetworkString("SendRound")
util.AddNetworkString("SendRounds")
util.AddNetworkString("SendRoundEnd")
util.AddNetworkString("RequestRoundsMenu")