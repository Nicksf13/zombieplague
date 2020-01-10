ConvarManager:CreateConVar("zp_can_repeat_map", 1, 8, "cvar used to set if it's possible to prolong the current map (0 = false, 1 = true)")
ConvarManager:CreateConVar("zp_rounds_to_extend", 10, 8, "cvar used to set how many rounds will be increased to the current map")
ZPVoteMap = {MapsToVote = {}, Voting = false}

function ZPVoteMap:StartVotemap(Prefixes)
	local MapsToVote = {}
	local Maps = file.Find("maps/*.bsp", "GAME")
	local CurrentMap = game.GetMap()
	local i = 0

	table.RemoveByValue(Maps, CurrentMap .. ".bsp")
	if cvars.Bool("zp_can_repeat_map", true) then
		MapsToVote[CurrentMap] = 0
		i = 1
	end
	
	while(#Maps > 0 && i < cvars.Number("zp_maps_to_vote", 7)) do
		local Map = string.Replace(table.remove(Maps, math.random(1, #Maps)), ".bsp", "")
		for k, Prefix in pairs(Prefixes) do
			if string.StartWith(Map, Prefix) then
				MapsToVote[Map] = 0
				i = i + 1
				break
			end
		end
	end
	local AuxVotemap = {}
	for MapName, Votes in pairs(MapsToVote) do
		AuxVotemap[MapName] = {}
		if MapName == CurrentMap then
			AuxVotemap[MapName].Description = "NoticeVotemapProlong"
			AuxVotemap[MapName].PhraseKeys = {"NoticeVotemapProlong"}
			AuxVotemap[MapName].PhraseValues = {
				RoundsToExtend = cvars.String("zp_rounds_to_extend", "5")
			}
			AuxVotemap[MapName].Order = 0
		else
			AuxVotemap[MapName].Description = MapName
			AuxVotemap[MapName].Order = 100
		end
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

	local MapsToVote = {}
	for Map, Votes in pairs(ZPVoteMap.MapsToVote) do
		table.insert(MapsToVote, {Map = Map, Votes = Votes})
	end
	table.sort(MapsToVote, function(a, b) return a.Votes > b.Votes end)
	local WinningMap = MapsToVote[1].Map
	local Phrase = "NoticeVotemapEnded"
	local Replace = "" .. WinningMap -- Copy the winning map
	local EndVoteFunction = function()
		RunConsoleCommand("changelevel", WinningMap)
	end

	if WinningMap == game.GetMap() then
		Phrase = "NoticeVotemapProlong"
		Replace = cvars.String("zp_rounds_to_extend", "5")
		EndVoteFunction = RoundManager.TryNewRound

		RoundManager:AddExtraRounds(cvars.Number("zp_rounds_to_extend", 5))
	else
		RoundManager:SetRoundState(ROUND_CHANGING_MAP)
	end

	RoundManager:SetTimer(5, EndVoteFunction)

	for k, ply in pairs(player.GetAll()) do
		SendColorMessage(ply, string.format(Dictionary:GetPhrase(Phrase, ply), Replace), Color(0, 255, 0))
	end
end
net.Receive("SendVotemap", function(len, ply)
	if ZPVoteMap.Voting then
		local Vote = net.ReadString()
		ZPVoteMap.MapsToVote[Vote] = ZPVoteMap.MapsToVote[Vote] + 1
	end
end)

util.AddNetworkString("SendVotemap")