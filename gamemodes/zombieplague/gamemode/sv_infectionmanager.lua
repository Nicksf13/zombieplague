InfectionManager = {}
--Main function to infect a player, ZPInfectionEvent are called here
function InfectionManager:Infect(Infected, Attacker)
	if cvars.Bool("zp_ap_zombies", false) then
		Attacker:GiveAmmoPacks(cvars.Number("zp_ap_zombies_total", 1))
	end
	
	Infected:Infect()
	local InfectionFunction = Attacker:GetZombieClass().InfectionFunction
	if InfectionFunction then
		InfectionFunction(Attacker, Infected)
	end
	
	Attacker:AddFrags(1)
	Infected:AddDeaths(1)
	
	if !RoundManager:IsRealisticMod() then
		for k, ply in pairs(player.GetAll()) do
			if Infected != Attacker then
				SendPopupMessage(ply, string.format(Dictionary:GetPhrase("NoticeInfect", ply), Infected:Name(), Attacker:Name()))
			else
				SendPopupMessage(ply, string.format(Dictionary:GetPhrase("NoticeSelfInfect", ply), Infected:Name()))
			end
		end
	end
	
	hook.Call("ZPInfectionEvent", GAMEMODE, Infected, Attacker)
	hook.Call("ZPResetAbilityEvent" .. Infected:SteamID64(), GAMEMODE)
	
	if RoundManager:LastHuman() then
		hook.Call("ZPLastHumanEvent")
	end
end
--Main function to cure a player, ZPCureEvent are called here
function InfectionManager:Cure(Cured, Attacker)
	Cured:Cure()
	Attacker:AddFrags(1)
	if !RoundManager:IsRealisticMod() then
		for k, ply in pairs(player.GetAll()) do
			if Cured != Attacker then
				SendPopupMessage(ply, string.format(Dictionary:GetPhrase("NoticeGetCured", ply), Cured:Name(), Attacker:Name()))
			else
				SendPopupMessage(ply, string.format(Dictionary:GetPhrase("NoticeAntidote", ply), Cured:Name()))
			end
		end
	end
	
	hook.Call("ZPCureEvent", GAMEMODE, Cured, Attacker)
	hook.Call("ZPResetAbilityEvent" .. Cured:SteamID64(), GAMEMODE)
	
	if RoundManager:LastZombie() then
		hook.Call("ZPLastZombieEvent")
	end
end