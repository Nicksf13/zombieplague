RoundManager = {}

function RoundManager:SetSpecialRound(SpecialRound)
	SetGlobalBool("SpecialRound", SpecialRound)
end
function RoundManager:SetRespawn(Respawn)
	SetGlobalBool("Respawn", Respawn)
end
function RoundManager:SetRound(Round)
	SetGlobalInt("Round", Round)
end
function RoundManager:SetRoundState(RoundState)
	SetGlobalInt("RoundState", RoundState)
end
function RoundManager:IsSpecialRound()
	return GetGlobalInt("SpecialRound", false)
end
function RoundManager:IsRespawn()
	return GetGlobalInt("Respawn", false)
end
function RoundManager:GetRound()
	return GetGlobalInt("Round", 0)
end
function RoundManager:GetRoundState()
	return GetGlobalInt("RoundState", ROUND_WAITING_PLAYERS)
end
function RoundManager:IsRealisticMod()
	return cvars.Bool("zp_realistic_mode", false)
end
function RoundManager:LastHuman()
	local i = 0
	for _, ply in ipairs(team.GetPlayers(TEAM_HUMANS)) do
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
	for _, ply in ipairs(team.GetPlayers(TEAM_ZOMBIES)) do
		if ply:Alive() then
			i = i + 1
			if i > 1 then
				return false
			end
		end
	end
	return i == 1
end
function RoundManager:NoHumans()
	for i, ply in ipairs(team.GetPlayers(TEAM_HUMANS)) do
		if ply:Alive() then
			return false
		end
	end
	return true
end
function RoundManager:NoZombies()
	for i, ply in pairs(team.GetPlayers(TEAM_ZOMBIES)) do
		if ply:Alive() then
			return false
		end
	end
	return true
end
function RoundManager:CountHumansAlive()
	local i = 0
	for _, ply in ipairs(team.GetPlayers(TEAM_HUMANS)) do
		if ply:Alive() and ply:GetObserverMode() == 0 then
			i = i + 1
		end
	end
	return i
end
function RoundManager:CountZombiesAlive()
	local i = 0
	for _, ply in ipairs(team.GetPlayers(TEAM_ZOMBIES)) do
		if ply:Alive() and ply:GetObserverMode() == 0 then
			i = i + 1
		end
	end
	return i
end
function RoundManager:GetAliveHumans()
	local AliveHumans = {}
	for i, ply in ipairs(team.GetPlayers(TEAM_HUMANS)) do
		if ply:Alive() then
			table.insert(AliveHumans, ply)
		end
	end
	return AliveHumans
end
function RoundManager:GetAliveZombies()
	local AliveZombies = {}
	for i, ply in ipairs(team.GetPlayers(TEAM_ZOMBIES)) do
		if ply:Alive() then
			table.insert(AliveZombies, ply)
		end
	end
	return AliveZombies
end