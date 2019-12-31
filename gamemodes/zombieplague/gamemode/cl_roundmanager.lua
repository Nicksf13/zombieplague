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
net.Receive("SyncTimer", function()
	RoundManager:SetTimer(net.ReadInt(16))
end)
net.Receive("SendRoundEnd", function()
	hook.Call("ZombiePlagueEndRound", GAMEMODE, net.ReadInt(4))
end)