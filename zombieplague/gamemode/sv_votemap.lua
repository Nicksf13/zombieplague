ZPVoteMap = {MapsToVote = {}, Voting = false}

function ZPVoteMap:StartVotemap(Prefixes)
	local MapsToVote = {}
	local Maps = file.Find("maps/*.bsp", "GAME")
	local i = 0
	local Map
	while(#Maps > 0 && i < cvars.Number("zp_maps_to_vote", 7)) do
		Map = table.remove(Maps, math.random(1, #Maps))
		for k, Prefix in pairs(Prefixes) do
			if string.StartWith(Map, Prefix) then
				table.insert(MapsToVote, {Name = string.Replace(Map, ".bsp", ""), Votes = 0})
				i = i + 1
				break
			end
		end
	end
	local AuxVotemap = {}
	for k, v in pairs(MapsToVote) do
		table.insert(AuxVotemap, v.Name)
	end
	net.Start("OpenBackMenu")
		net.WriteString("SendVotemap")
		net.WriteTable(AuxVotemap)
	net.Broadcast()
	
	ZPVoteMap.MapsToVote = MapsToVote
	ZPVoteMap.Voting = true
	RoundManager:SetRoundState(ROUND_VOTEMAP)
	RoundManager:SetTimer(10, ZPVoteMap.EndVotemap)
end
function ZPVoteMap:EndVotemap()
	ZPVoteMap.Voting = false
	table.sort(ZPVoteMap.MapsToVote, function(a, b) return a.Votes > b.Votes end)
	local WinningMap = ZPVoteMap.MapsToVote[1].Name
	
	for k, ply in pairs(player.GetAll()) do
		SendColorMessage(ply, string.format(Dictionary:GetPhrase("NoticeVotemapEnded", ply), WinningMap), Color(0, 255, 0))
	end
	
	RoundManager:SetRoundState(ROUND_CHANGING_MAP)
	RoundManager:SetTimer(5, function()
		RunConsoleCommand("changelevel", WinningMap)
	end)
end
net.Receive("SendVotemap", function(len, ply)
	if ZPVoteMap.Voting then
		local Vote = net.ReadInt(16)
		ZPVoteMap.MapsToVote[Vote].Votes = ZPVoteMap.MapsToVote[Vote].Votes + 1
	end
end)

util.AddNetworkString("SendVotemap")