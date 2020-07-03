ConvarManager:CreateConVar("zp_min_players", 2, 8, "cvar used to define minimun players to start the round.")
ConvarManager:CreateConVar("zp_newround_delay", 10, 8, "cvar used to define new round time delay.")
ConvarManager:CreateConVar("zp_infection_delay", 10, 8, "cvar used to define infection time delay.")
ConvarManager:CreateConVar("zp_max_rounds", 10, 8, "cvar used to define the total of rounds.")
ConvarManager:CreateConVar("zp_round_time", 300, 8, "cvar used to define round time")

RoundManager.Rounds = {}
RoundManager.PlayersToPlay = {}
RoundManager.ExtraRounds = 0
function RoundManager:SearchRounds()
	RoundManager:AddDefaultRounds() -- Cleanest way to do this

	local Files = file.Find("zombieplague/gamemode/rounds/*.lua", "LUA")
	if Files then
		for k, File in pairs(Files) do
			local RoundToAdd = {}
			RoundToAdd.MinPlayers = cvars.Number("zp_min_players", 2)
			RoundToAdd.Chance = 100
			RoundToAdd.SpecialRound = false
			RoundToAdd.Respawn = false
			RoundToAdd.ShouldBeEnabled = function()return true end
			RoundToAdd.Order = 100
			include("zombieplague/gamemode/rounds/" .. File)
			
			if RoundToAdd:ShouldBeEnabled() then
				if !RoundToAdd.StartFunction || !RoundToAdd.Name then
					print("Invalid round format: '" .. File .. "'!")
				else
					RoundManager:AddRoundType(RoundToAdd)
				end
			end
		end
	end
end
function RoundManager:AddExtraRounds(ExtraRounds)
	self.ExtraRounds = self.ExtraRounds + ExtraRounds
end
function RoundManager:AddRoundType(RoundID, RoundType)
	RoundManager.Rounds[RoundID] = RoundType
	if RoundType.StartSound then
		for k, SoundPath in pairs(RoundType.StartSound) do
			resource.AddFile("sound/" .. SoundPath)
		end
	end
end
function RoundManager:GetServerStatus(Requester)
	local ServerStatus = {
		Timer = RoundManager:GetTime(),
		RoundState = RoundManager:GetRoundState(),
		Round = RoundManager:GetRound(),
		Players = {}
	}

	for k, ply in pairs(RoundManager:GetPlayersToPlay()) do
		table.insert(ServerStatus.Players, {ID = PlayerManager:GetPlayerID(ply),
			AmmoPacks = ply:GetAmmoPacks(),
			Battery = ply:GetMaxBatteryCharge(),
			ZombieClass = ply:GetZombieClass().Name,
			HumanClass = ply:GetHumanClass().Name,
			Light = ply:GetLight(),
			Footstep = ply:GetFootstep(),
			AbilityPower = ply:GetAbilityPower(),
			MaxAbilityPower = ply:GetMaxAbilityPower()
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
function RoundManager:CheckRoundEnd()
	local CurrentRoundPlaying = RoundManager:GetCurrentRoundPlaying()

	if CurrentRoundPlaying.Respawn && CurrentRoundPlaying.RoundEndFunction then
		CurrentRoundPlaying:RoundEndFunction()
	else
		local HumansAlive = RoundManager:CountHumansAlive()
		local ZombiesAlive = RoundManager:CountZombiesAlive()
		if HumansAlive == 0 && ZombiesAlive == 0 then
			RoundManager:EndRound(ROUND_DRAW)
		elseif HumansAlive == 0 then
			RoundManager:EndRound(ZOMBIES_WIN)
		elseif ZombiesAlive == 0 then
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
	end
	return false
end
function RoundManager:TryNewRound()
	if RoundManager:Prepare() then
		RoundManager:SetTimer(cvars.Number("zp_infection_delay",  10), RoundManager.NewRound)
	else
		RoundManager:WaitPlayers()
	end

	for k, ply in pairs(player.GetAll()) do
		hook.Call("ZPResetAbilityEvent" .. ply:SteamID64(), GAMEMODE)
	end
end
function RoundManager:NewRound()
	local TotalChance = 0
	local ValidRounds = {}
	local TotalPlayers = RoundManager:CountPlayersToPlayAlive()
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
		BroadcastSound(SafeTableRandom(DrawSounds))
	end

	if RoundManager:GetRound() < (cvars.Number("zp_max_rounds", 10) + self.ExtraRounds) then
		RoundManager:SetRoundState(ROUND_ENDING)
		RoundManager:SetTimer(cvars.Number("zp_newround_delay",  10), RoundManager.TryNewRound)
	else
		ZPVoteMap:StartVotemap(ALLOWED_PREFIX)
	end
	hook.Call("ZPEndRound", GAMEMODE, Reason)
end
function RoundManager:RoundsLeft()
	return (cvars.Number("zp_max_rounds", 10) + self.ExtraRounds) - RoundManager:GetRound()
end
function RoundManager:StartRound(RoundToStart, ply)
	hook.Call("ZPPreNewRound", GAMEMODE, RoundToStart)
	RoundToStart.StartFunction(ply)
	self:SetSpecialRound(RoundToStart.SpecialRound)
	self:SetRespawn(RoundToStart.Respawn)
	if RoundToStart.StartSound then
		BroadcastSound(SafeTableRandom(RoundToStart.StartSound))
	end

	self:SetTimer(cvars.Number("zp_round_time", 300), function()
		self:EndRound(ROUND_DRAW)
	end)

	self:SetRound(self:GetRound() + 1)
	self:SetRoundState(ROUND_PLAYING)
	self.RoundPlaying = RoundToStart

	hook.Call("ZPNewRound", GAMEMODE, RoundToStart, self:GetRound())
end
function RoundManager:GetCurrentRoundPlaying()
	return self.RoundPlaying
end

function RoundManager:GetGoodRounds()
	local GoodRounds = {}
	local TotalPlayers = RoundManager:CountPlayersToPlayAlive()
	for k, Round in pairs(RoundManager:GetRounds()) do
		if TotalPlayers >= Round.MinPlayers then
			GoodRounds[k] = Round
		end
	end

	return GoodRounds
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
	local Pretty = {}
	local GoodRounds = RoundManager:GetGoodRounds()

	for RoundID, Round in pairs(GoodRounds) do
		Pretty[RoundID] = {
			Description = Dictionary:GetPhrase(Round.Name, ply),
			Order = Round.Order
		}
	end
	
	net.Start("OpenBackMenu")
		net.WriteString("SendRounds")
		net.WriteTable(Pretty)
		net.WriteBool(false)
	net.Send(ply)
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
	
	if RoundManager:GetRoundState() == ROUND_PLAYING then
		RoundManager:CheckRoundEnd()
	end

	hook.Call("ZPResetAbilityEvent" .. ply:SteamID64(), GAMEMODE)
end
function RoundManager:CountPlayersToPlay()
	local PlayersToPlay = 0
	for k, ply in pairs(self.PlayersToPlay) do
		if IsValid(ply) then
			PlayersToPlay = PlayersToPlay + 1
		end
	end

	return PlayersToPlay
end
function RoundManager:CountPlayersToPlayAlive()
	local Alive = 0
	for k, ply in pairs(self.PlayersToPlay) do
		if IsValid(ply) && ply:Alive() then
			Alive = Alive + 1
		end
	end

	return Alive
end
function RoundManager:GetPlayersToPlay(Alive)
	local PlayersToPlay = {}

	for k, ply in pairs(self.PlayersToPlay) do
		if IsValid(ply) then
			if !Alive || ply:Alive() then
				table.insert(PlayersToPlay, ply)
			end
		else
			table.remove(self.PlayersToPlay, k)
		end
	end

	return PlayersToPlay
end
function RoundManager:AddDefaultRounds()
	local ROUND = {}
	ROUND.Name = "RoundSimpleName"
	ROUND.MinPlayers = cvars.Number("zp_min_players", 2)
	ROUND.Chance = 100
	ROUND.SpecialRound = false
	ROUND.Respawn = false
	ROUND.Order = 1
	ROUND.StartFunction = function(ply)
		local FirstZombie = (ply and ply or table.Random(RoundManager:GetPlayersToPlay(true)))
		FirstZombie:Infect()
		for k, ply in pairs(player.GetAll()) do
			SendNotifyMessage(ply, Dictionary:GetPhrase("RoundSimple", ply), 5, Color(0, 255, 0))
			SendPopupMessage(ply, string.format(Dictionary:GetPhrase("NoticeFirstZombie", ply), FirstZombie:Name()))
		end
	end
	ROUND.RespawnFunction = function(ply)
		return RoundManager:CountHumansAlive() > 1
	end

	RoundManager:AddRoundType("SimpleRound", ROUND)
	
	ROUND = {}
	ROUND.Name = "RoundMultiInfectionName"
	ROUND.Chance = 15
	ROUND.MinPlayers = 4
	ROUND.Order = 2
	ROUND.Respawn = false
	ROUND.StartFunction = function()
		local ValidPlayers = RoundManager:GetPlayersToPlay(true)
		table.remove(ValidPlayers, math.random(1, table.Count(ValidPlayers))):Infect()
		table.remove(ValidPlayers, math.random(1, table.Count(ValidPlayers))):Infect()
		
		for k, ply in pairs(player.GetAll()) do
			SendNotifyMessage(ply, Dictionary:GetPhrase("NoticeMultiInfection", ply), 5, Color(0, 255, 0))
		end
	end
	ROUND.RespawnFunction = function(ply)
		return RoundManager:CountHumansAlive() > 1
	end

	RoundManager:AddRoundType("MultiInfectionRound", ROUND)
	
	ROUND = {}
	ROUND.Name = "RoundNemesisName"
	ROUND.Chance = 5
	ROUND.MinPlayers = 5
	ROUND.SpecialRound = true
	ROUND.Respawn = false
	ROUND.StartSound = {"zombieplague/nemesis1.mp3", "zombieplague/nemesis2.mp3"}
	ROUND.Order = 3
	ROUND.StartFunction = function()
		local Nemesis = SafeTableRandom(RoundManager:GetPlayersToPlay(true))

		Nemesis:MakeNemesis()
		
		for k, ply in pairs(player.GetAll()) do
			SendPopupMessage(ply, string.format(Dictionary:GetPhrase("NoticeNemesis", ply), Nemesis:Name()))

			if ROUND.Respawn && ply:IsHuman() then
				ply.Lifes = 5
			end
		end
	end
	if ROUND.Respawn then
		ROUND.OnDeathFunction = function(ply)
			ply.Lifes = (ply.Lifes or 0) - 1
		end
		ROUND.RespawnFunction = function(ply)
			return ply.Lifes > 0
		end
	end
	RoundManager:AddRoundType("NemesisRound", ROUND)
	
	ROUND = {}
	ROUND.Name = "RoundSurvivorName"
	ROUND.Chance = 5
	ROUND.MinPlayers = 3
	ROUND.SpecialRound = true
	ROUND.StartSound = {"zombieplague/survivor1.mp3", "zombieplague/survivor2.mp3"}
	ROUND.Order = 4
	ROUND.StartFunction = function()
		local Players = RoundManager:GetPlayersToPlay(true)
		local Survivor = table.Random(Players)
		table.RemoveByValue(Players, Survivor)
		for k, ply in pairs(Players) do
			if ROUND.Respawn then
				ply.Lifes = 5
			end
			ply:Infect()
			SendNotifyMessage(ply, string.format(Dictionary:GetPhrase("NoticeSurvivor", ply), Survivor:Name()), 5, SURVIVOR_COLOR)
		end
		Survivor:MakeSurvivor()
	end
	if ROUND.Respawn then
		ROUND.OnDeathFunction = function(ply)
			ply.Lifes = (ply.Lifes or 0) - 1
		end
		ROUND.RespawnFunction = function(ply)
			return ply.Lifes > 0
		end
	end
	RoundManager:AddRoundType("SurvivalRound", ROUND)
	
	ROUND = {}
	ROUND.Name = "RoundSwarmName"
	ROUND.Chance = 10
	ROUND.MinPlayers = 4
	ROUND.SpecialRound = true
	ROUND.StartSound = {"zombieplague/swarmmode.mp3"}
	ROUND.Order = 5
	ROUND.StartFunction = function()
		local Players = RoundManager:GetPlayersToPlay(true)
		local i = 1
		while(table.Count(Players) > 0) do
			local v = table.Random(Players)
			table.RemoveByValue(Players, v)
			if i % 2 == 0 then
				v:Infect()
			end
			i = i + 1
		end
		for k, ply in pairs(player.GetAll()) do
			SendNotifyMessage(ply, Dictionary:GetPhrase("NoticeSwarm", ply), 5, Color(0, 255, 0))
		end
	end
	RoundManager:AddRoundType("SwarmRound", ROUND)
	
	ROUND = {}
	ROUND.Name = "RoundPlagueName"
	ROUND.Chance = 10
	ROUND.MinPlayers = 4
	ROUND.SpecialRound = true
	ROUND.StartSound = {"zombieplague/plaguemode.mp3"}
	ROUND.Order = 6
	ROUND.StartFunction = function()
		local Players = RoundManager:GetPlayersToPlay(true)
		local i = 1
		while(table.Count(Players) > 0) do
			local v = table.Random(Players)
			table.RemoveByValue(Players, v)
			if i % 2 == 0 then
				v:Infect()
			end
			i = i + 1
		end
		SafeTableRandom(RoundManager:GetAliveZombies()):MakeNemesis()
		SafeTableRandom(RoundManager:GetAliveHumans()):MakeSurvivor()
		
		for k, ply in pairs(player.GetAll()) do
			SendNotifyMessage(ply, Dictionary:GetPhrase("NoticePlague", ply), 5, team.GetColor(ply:Team()))
		end
	end
	RoundManager:AddRoundType("PlagueRound", ROUND)
end
hook.Add("PostPlayerDeath", "RoundEndCheck", function(ply)
	if RoundManager:GetRoundState() == ROUND_PLAYING then
		local OnDeathFunction = RoundManager:GetCurrentRoundPlaying().OnDeathFunction
		if OnDeathFunction then
			OnDeathFunction(ply)
		end
		timer.Create("ZPEndRound" .. CurTime(), 0.1, 1, RoundManager.CheckRoundEnd)
	end
end)
net.Receive("SendRounds", function(len, ply)
	if (ply:IsAdmin() || ply:IsSuperAdmin()) && RoundManager:GetRoundState() == ROUND_STARTING_NEW_ROUND then
		local Round = RoundManager:GetGoodRounds()[net.ReadString()]
		if Round then
			RoundManager:StartRound(Round)
			for k, Play in pairs(player.GetAll()) do
				SendPopupMessage(Play, string.format(Dictionary:GetPhrase("NoticeForceRound", Play), ply:Name(), Dictionary:GetPhrase(Round.Name, ply)))
			end
		else
			SendPopupMessage(ply, Dictionary:GetPhrase("NoticeNotAllowed", ply))
		end
	else
		SendPopupMessage(ply, Dictionary:GetPhrase("NoticeNotAllowed", ply))
	end
end)
net.Receive("RequestRoundsMenu", function(len, ply)
	if ply:IsAdmin() || ply:IsSuperAdmin() then
		RoundManager:OpenRoundsMenu(ply)
	else
		SendPopupMessage(ply, Dictionary:GetPhrase("NoticeNotAllowed", ply))
	end
end)

util.AddNetworkString("SyncTimer")
util.AddNetworkString("SendRounds")
util.AddNetworkString("SendRoundEnd")
util.AddNetworkString("RequestRoundsMenu")