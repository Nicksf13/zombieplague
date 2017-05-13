InfectionManager = {}
--Main function to infect a player, ZPInfectionEvent are called here
function InfectionManager:Infect(Infected, Attacker)
	if cvars.Bool("zp_ap_zombies", false) then
		Attacker:AddAmmoPacks(cvars.Number("zp_ap_zombies_total", 1))
	end
	
	Infected:Infect()
	local InfectionFunction = Attacker:GetZombieClass().InfectionFunction
	if InfectionFunction != nil then
		InfectionFunction(Attacker, Infected)
	end
	Attacker:AddFrags(1)
	Infected:AddDeaths(1)
	
	if !RoundManager:IsRealisticMod() then
		for k, ply in pairs(player.GetAll()) do
			SendPopupMessage(ply, string.format(Dictionary:GetPhrase("NoticeInfect", ply), Infected:Name(), Attacker:Name()))
		end
	end
	
	hook.Call("ZPInfectionEvent", GAMEMODE, Infected, Attacker)
	
	if RoundManager:LastHuman() then
		hook.Call("ZPLastHumanEvent")
	end
end
--Main function to infect a player, ZPCureEvent are called here
function InfectionManager:Cure(Infected, Attacker)
	Infected:Cure()
	
	if !RoundManager:IsRealisticMod() then
		if Infected == Attacker then
			for k, ply in pairs(player.GetAll()) do
				SendPopupMessage(ply, string.format(Dictionary:GetPhrase("NoticeAntidote", ply), Infected:Name()))
			end
		else
			Attacker:AddFrags(1)
			for k, ply in pairs(player.GetAll()) do
				SendPopupMessage(ply, string.format(Dictionary:GetPhrase("NoticeGetCured", ply), Infected:Name(), Attacker:Name()))
			end
		end
	end
	
	hook.Call("ZPCureEvent", GAMEMODE, Infected, Attacker)
	
	if RoundManager:LastZombie() then
		hook.Call("ZPLastZombieEvent")
	end
end