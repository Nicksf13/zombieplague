ExtraItem.Name = "Antidote Bullets"
ExtraItem.Price = 100
function ExtraItem:OnBuy(ply)
	ply.AntidoteBullets = (ply.AntidoteBullets or 0) + 5
	hook.Add("EntityFireBullets", "EntityFireBullets"..ply:SteamID64(), function(Attacker)
		if Attacker == ply && !RoundManager:IsSpecialRound() && Attacker.AntidoteBullets && Attacker.AntidoteBullets > 0 then
			Attacker.AntidoteBullets = Attacker.AntidoteBullets - 1
			SendPopupMessage(Attacker, string.format(Dictionary:GetPhrase("BulletsLeft", Attacker), Attacker.AntidoteBullets))
		end
	end)
	hook.Add("ZPHumanDamage", "AntidoteBullets"..ply:SteamID64(), function(Target, Attacker)
		if Attacker == ply && !RoundManager:IsSpecialRound() then
			if Attacker.AntidoteBullets > 0 then
				if !RoundManager:LastZombie() then
					InfectionManager:Cure(Target, Attacker)
				end
			else
				hook.Remove("EntityFireBullets", "EntityFireBullets"..Attacker:SteamID64())
				hook.Remove("ZPHumanDamage", "AntidoteBullets"..Attacker:SteamID64())
			end
		end
	end)
end
function ExtraItem:CanBuy(ply)
	return !RoundManager:IsSpecialRound() && !RoundManager:LastZombie() && ply:Alive()
end

Dictionary:RegisterPhrase("Português Brasileiro", "BulletsLeft", "Você tem %d bala(s) de antidoto restante(s).")
Dictionary:RegisterPhrase("English", "BulletsLeft", "You have %d Antidote Bullets left.")