ExtraItem.ID = "ZPAntidoteBullets"
ExtraItem.Name = "ExtraItemAntidoteBulletsName"
ExtraItem.Price = 100
function ExtraItem:OnBuy(ply)
	ply.AntidoteBullets = (ply.AntidoteBullets or 0) + 5
	hook.Add("EntityFireBullets", "EntityFireBullets"..ply:SteamID64(), function(Attacker)
		if Attacker == ply && !RoundManager:IsSpecialRound() && Attacker.AntidoteBullets then
			if Attacker.AntidoteBullets > 0 then
				Attacker.AntidoteBullets = Attacker.AntidoteBullets - 1
				SendPopupMessage(Attacker, string.format(Dictionary:GetPhrase("ExtraItemAntidoteBulletsLeft", Attacker), Attacker.AntidoteBullets))
			else
				hook.Remove("EntityFireBullets", "EntityFireBullets"..Attacker:SteamID64())
				hook.Remove("ZPHumanDamage", "AntidoteBullets"..Attacker:SteamID64())
			end
		end
	end)
	hook.Add("ZPHumanDamage", "AntidoteBullets"..ply:SteamID64(), function(Target, Attacker, DmgInfo)
		local DmgListToIgnore = {
			DMG_CRUSH
		}

		local ShouldIgnore = false
		for k, DmgType in pairs(DmgList) do
			if DmgInfo:IsDamageType(DmgType) then
				ShouldIgnore = true
				break
			end
		end
		
		if !ShouldIgnore && Attacker == ply && !RoundManager:IsSpecialRound() then
			if !RoundManager:LastZombie() then
				InfectionManager:Cure(Target, Attacker)
			end
		end
	end)
	hook.Add("ZPInfectionEvent", "ZPInfectionEvent"..ply:SteamID64(), function(Infected, Attacker)
		if Infected == ply then
			ply.AntidoteBullets = 0
			hook.Remove("EntityFireBullets", "EntityFireBullets"..ply:SteamID64())
			hook.Remove("ZPHumanDamage", "AntidoteBullets"..ply:SteamID64())
			hook.Remove("ZPInfectionEvent", "ZPInfectionEvent"..ply:SteamID64())

			SendPopupMessage(Attacker, Dictionary:GetPhrase("ExtraItemAntidoteBulletsLost", Attacker))
		end
	end)
end
function ExtraItem:CanBuy(ply)
	return !RoundManager:IsSpecialRound() && !RoundManager:LastZombie() && ply:Alive()
end