ROUND.Name = "Plague Deathmatch"
ROUND.Chance = 5
ROUND.MinPlayers = 4
ROUND.SpecialRound = true
ROUND.Deathmatch = true
ROUND.StartSound = {"zombieplague/plaguemode.mp3"}
function ROUND:StartFunction()
	local Players = RoundManager:GetPlayersToPlay(true)
	local i = 1
	while(table.Count(Players) > 0) do
		local v = table.Random(Players)
		table.RemoveByValue(Players, v)
		i % 2 == 1 and v:MakeNemesis() or v:MakeSurvivor()
		i = i + 1
	end
	
	for k, ply in pairs(player.GetAll()) do
		SendNotifyMessage(ply, Dictionary:GetPhrase("RoundPlague", ply), 5, team.GetColor(ply:Team()))
	end
end