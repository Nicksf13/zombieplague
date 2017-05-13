RoundManager = {RoundState = 0, Round = 0}
function RoundManager:SetRoundState(RoundState)
	self.RoundState = RoundState
end
function RoundManager:GetRoundState()
	return self.RoundState
end
function RoundManager:SetTimer(Timer)
	self.Timer = CurTime() + Timer
end
function RoundManager:GetTimer()
	local Time = (self.Timer or 0) - CurTime()
	if Time < 0 then
		Time = 0
	end
	return Time
end
function RoundManager:SetRound(Round)
	RoundManager.Round = Round
end
function RoundManager:GetRound()
	return RoundManager.Round
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
net.Receive("SendRoundState", function()
	RoundManager:SetRoundState(net.ReadInt(4))
end)
net.Receive("SyncTimer", function()
	RoundManager:SetTimer(net.ReadInt(16))
end)
net.Receive("SendRound", function()
	RoundManager:SetRound(net.ReadInt(8))
end)
net.Receive("SendRoundEnd", function()
	hook.Call("ZombiePlagueEndRound", GAMEMODE, net.ReadInt(4))
end)