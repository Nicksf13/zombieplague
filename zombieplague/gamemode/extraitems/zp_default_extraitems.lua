local InfectionBomb = {Name = "Infection Bomb", Price = 10}
function InfectionBomb:OnBuy(ply)
	ply:GiveZombieAllowedWeapon(INFECTION_BOMB)
end
ExtraItemsManager:AddZombieExtraItem(InfectionBomb)

local Antidote = {Name = "Antidote", Price = 20}
function Antidote:OnBuy(ply)
	InfectionManager:Cure(ply, ply)
end
function Antidote:CanBuy(ply)
	return !RoundManager:LastZombie() && ply:Alive()
end
ExtraItemsManager:AddZombieExtraItem(Antidote)

local ZombieMadness = {Name = "Zombie Madness", Price = 15}
function ZombieMadness:OnBuy(ply)
	ply:SetLight(Color(255, 0, 0))
	ply:GodEnable()
	ply:ZPEmitSound(SafeTableRandom(ZombieMadness), 5, true)
	timer.Create("ZPGod" .. ply:SteamID64(), 5, 1, function()
		ply:SetLight(nil)
		ply:GodDisable()
	end)
end
ExtraItemsManager:AddZombieExtraItem(ZombieMadness)

local Armor = {Name = "Armor", Price = 10}
function Armor:OnBuy(ply)
	ply:SetArmor(ply:Armor() + 100)
end
ExtraItemsManager:AddHumanExtraItem(Armor)

local Grenade = {Name = "Grenade", Price = 5}
function Grenade:OnBuy(ply)
	local Weap = ply:Give("weapon_frag")
	ply:GiveAmmo(1, Weap:GetPrimaryAmmoType(), true) 
end
ExtraItemsManager:AddHumanExtraItem(Grenade)

local Slam = {Name = "S.L.A.M", Price = 10}
function Slam:OnBuy(ply)
	local Weap = ply:Give("weapon_slam")
	ply:GiveAmmo(1, Weap:GetPrimaryAmmoType(), true) 
end
ExtraItemsManager:AddHumanExtraItem(Slam)