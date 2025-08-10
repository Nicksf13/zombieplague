ConvarManager:CreateConVar("zp_max_allowed_primary_weapons", 1, 8, "cvar used to define how many primary weapons a player can have")
ConvarManager:CreateConVar("zp_max_allowed_secondary_weapons", 1, 8, "cvar used to define how many secondary weapons a player can have")
ConvarManager:CreateConVar("zp_max_allowed_melee_weapons", 1, 8, "cvar used to define how many melee weapons a player can have")

WEAPON_PRIMARY = 1
WEAPON_SECONDARY = 2
WEAPON_MELEE = 3

NATIVE_WEAPONS = {
	"weapon_357",
	"weapon_ar2",
	"weapon_crossbow",
	"weapon_pistol",
	"weapon_smg1",
	"weapon_shotgun",
	"weapon_crowbar",
	"weapon_stunstick"
}

WeaponManager = {PrimaryWeapons = {}, SecondaryWeapons = {}, MeleeWeapons = {}, WeaponsMultiplier = {}, ServerWeapons = NATIVE_WEAPONS}

function WeaponManager:SearchWeapons()
	for k, Weapon in pairs(weapons.GetList()) do
		table.insert(self.ServerWeapons, Weapon.ClassName)
	end

	local Files = Utils:RecursiveFileSearch("zombieplague/gamemode/weapons", ".lua")
	if Files then
		for k, File in pairs(Files) do
			Weapon = WeaponManager:CreateNewWeapon()

			include(File)
			
			if !Weapon.PrettyName then
				Utils:Print(WARNING_MESSAGE, "Cannot load: '" .. File .. "', unknown 'Pretty Name'!")
			elseif !Weapon.WeaponID then
				Utils:Print(WARNING_MESSAGE, "Cannot load: '" .. File .. "', unknown 'WeaponID'!")
			elseif !WeaponManager:IsValidWeaponType(Weapon.WeaponType) then
				Utils:Print(WARNING_MESSAGE, "Cannot load: '" .. File .. "', Invalid weapon type!")
			elseif WeaponManager:ServerHasWeapon(Weapon.WeaponID) && Weapon:ShouldBeEnabled() then
				self:AddWeapon(Weapon, Weapon.WeaponType)
			end
		end
	end
end

function WeaponManager:ServerHasWeapon(WeaponClass)
	for k, Weapon in pairs(self.ServerWeapons) do
		if Weapon == WeaponClass then
			return true
		end
	end

	return false
end
function WeaponManager:IsChoosableWeapon(Weap)
	for k, Weapon in pairs(self.PrimaryWeapons) do
		if Weapon.WeaponID == Weap then
			return true
		end
	end
	for k, Weapon in pairs(self.SecondaryWeapons) do
		if Weapon.WeaponID == Weap then
			return true
		end
	end

	return false
end
function WeaponManager:IsValidWeaponType(WeaponType)
	return WeaponType == WEAPON_PRIMARY ||
	WeaponType == WEAPON_SECONDARY ||
	WeaponType == WEAPON_MELEE
end
function WeaponManager:CreateNewWeapon()
	local Weapon = {}
	Weapon.WeaponType = WEAPON_PRIMARY
	Weapon.DamageMultiplier = 1
	Weapon.Order = 100
	function Weapon:GiveWeapon(ply)
		local Weap = ply:GetWeapon(self.WeaponID)

    	if !IsValid(Weap) then
    	    Weap = ply:Give(self.WeaponID)
    	end

		if Weap:GetMaxClip1() then
			ply:GiveAmmo(Weap:GetMaxClip1() * 10, Weap:GetPrimaryAmmoType(), true) 
		else
			ply:GiveAmmo(Weap:GetMaxClip2() * 10, Weap:GetSecondaryAmmoType(), true) 
		end
	end
	function Weapon:ShouldBeEnabled()
		return true
	end

	return Weapon
end
function WeaponManager:GetWeaponMultiplier(Weapon)
	return self.WeaponsMultiplier[Weapon]
end
function WeaponManager:AddWeaponMultiplier(WeaponID, DamageMultiplier)
	self.WeaponsMultiplier[WeaponID] = DamageMultiplier
end
function WeaponManager:AddWeapon(Weapon, WeaponType)
	local Weapons = self:GetWeaponsTableByWeaponType(WeaponType)

	Weapons[Weapon.WeaponID] = Weapon

	WeaponManager:AddWeaponMultiplier(Weapon.ProjectileID and Weapon.ProjectileID or Weapon.WeaponID, Weapon.DamageMultiplier)
end
function WeaponManager:GetPrimaryWeapons()
	return self.PrimaryWeapons
end
function WeaponManager:GetSecondaryWeapons()
	return self.SecondaryWeapons
end
function WeaponManager:GetMeleeWeapons()
	return self.MeleeWeapons
end
function WeaponManager:PlayerCanPickupWeapon(Ply, WeaponClass)
	local PrimaryWeapons = self:GetWeaponsTableByWeaponType(WEAPON_PRIMARY)

	if PrimaryWeapons[WeaponClass] then
		return self:CountPlayerWeaponsByWeaponType(Ply, WEAPON_PRIMARY) < cvars.Number("zp_max_allowed_primary_weapons", 1)
	end

	local SecondaryWeapons = self:GetWeaponsTableByWeaponType(WEAPON_SECONDARY)

	if SecondaryWeapons[WeaponClass] then
		return self:CountPlayerWeaponsByWeaponType(Ply, WEAPON_SECONDARY) < cvars.Number("zp_max_allowed_secondary_weapons", 1)
	end

	local MeeleWeapons = self:GetWeaponsTableByWeaponType(WEAPON_MELEE)

	if MeeleWeapons[WeaponClass] then
		return self:CountPlayerWeaponsByWeaponType(Ply, WEAPON_MELEE) < cvars.Number("zp_max_allowed_melee_weapons", 1)
	end

	return true
end
function WeaponManager:CountPlayerWeaponsByWeaponType(Ply, WeaponType)
	local Weapons = self:GetWeaponsTableByWeaponType(WeaponType)

	local Amount = 0
	for _, Weapon in pairs(Ply:GetWeapons()) do
		if Weapons[Weapon:GetClass()] then
			Amount = Amount + 1
		end
	end

	return Amount
end
function WeaponManager:GetWeaponsTableByWeaponType(WeaponType)
	if WeaponType == WEAPON_PRIMARY then
		return self.PrimaryWeapons
	end
	if WeaponType == WEAPON_SECONDARY then
		return self.SecondaryWeapons
	end

	return self.MeleeWeapons
end
function WeaponManager:FindWeaponByWeaponId(ID, WeaponType)
	for k, Weapon in pairs(self:GetWeaponsTableByWeaponType(WeaponType)) do
		if Weapon.WeaponID == ID then
			return Weapon
		end
	end

	return nil
end

function WeaponManager:IsChosenWeapon(Weapon)
	for k, Weap in pairs(self.PrimaryWeapons) do
		if Weap.WeaponID == Weapon then
			return true
		end
	end
	for k, Weap in pairs(self.SecondaryWeapons) do
		if Weap.WeaponID == Weapon then
			return true
		end
	end
	return false
end
function WeaponManager:GetWeaponMenu(ply, WeaponType)
	local PrettyWeapons = {}
	for k, Weapon in pairs(self:GetWeaponsTableByWeaponType(WeaponType)) do
		PrettyWeapons[Weapon.WeaponID] = {
			Description = Weapon.PrettyName,
			Order = Weapon.Order
		}
	end

	return PrettyWeapons
end
function WeaponManager:OpenWeaponMenu(ply, WeaponType)
	local FixedOptions = {
		ShouldSaveWeapon = {
			DescribeText = Dictionary:GetPhrase("SaveSelection", ply),
			Type = "Boolean",
			Value = WeaponManager:IsWeaponTypeSet(ply, WeaponType)
		}
	}

	net.Start("OpenBackMenu")
		net.WriteString(WeaponManager:GetWeaponNetworkString(WeaponType))
		net.WriteTable(WeaponManager:GetWeaponMenu(ply, WeaponType))
		net.WriteBool(true)
		net.WriteTable(FixedOptions)
	net.Send(ply)
end
function WeaponManager:IsWeaponTypeSet(ply, WeaponType)
	if WeaponType == WEAPON_PRIMARY then
		return !!ply:GetPrimaryWeapon()
	end

	if WeaponType == WEAPON_SECONDARY then
		return !!ply:GetSecondaryWeapon()
	end

	return !!ply:GetMeleeWeapon()
end
function WeaponManager:GetWeaponNetworkString(WeaponType)
	if WeaponType == WEAPON_PRIMARY then
		return "SendPrimaryWeapon"
	end

	if WeaponType == WEAPON_SECONDARY then
		return "SendSecondaryWeapon"
	end

	return "SendMeleeWeapon"
end
net.Receive("SendPrimaryWeapon", function(len, ply)
	local WeaponID = net.ReadString()
	local Weapon = WeaponManager:FindWeaponByWeaponId(WeaponID, WEAPON_PRIMARY)
	local ShouldSaveWeapon = false
	if net.ReadBool() then
		ShouldSaveWeapon = net.ReadTable().ShouldSaveWeapon.Value
	end

	if ShouldSaveWeapon then
		ply:SetPrimaryWeapon(Weapon)
	elseif !ply:GetPrimaryWeaponGiven() then
		ply:GiveWeapon(Weapon)
		ply:SetPrimaryWeaponGiven(true)
	end

	if !ShouldSaveWeapon then
		ply:SetPrimaryWeapon(nil)
	end

	if !ply:GetSecondaryWeaponGiven() then
		WeaponManager:OpenWeaponMenu(ply, WEAPON_SECONDARY)
	elseif !ply:GetMeleeWeaponGiven() then
		WeaponManager:OpenWeaponMenu(ply, WEAPON_MELEE)
	end
end)
net.Receive("SendSecondaryWeapon", function(len, ply)
	local WeaponID = net.ReadString()
	local Weapon = WeaponManager:FindWeaponByWeaponId(WeaponID, WEAPON_SECONDARY)
	local ShouldSaveWeapon = false
	if net.ReadBool() then
		ShouldSaveWeapon = net.ReadTable().ShouldSaveWeapon.Value
	end

	if ShouldSaveWeapon then
		ply:SetSecondaryWeapon(Weapon)
	elseif !ply:GetSecondaryWeaponGiven() then
		ply:GiveWeapon(Weapon)
		ply:SetSecondaryWeaponGiven(true)
	end

	if !ShouldSaveWeapon then
		ply:SetSecondaryWeapon(nil)
	end

	if !ply:GetPrimaryWeaponGiven() then
		WeaponManager:OpenWeaponMenu(ply, WEAPON_PRIMARY)
	elseif !ply:GetMeleeWeaponGiven() then
		WeaponManager:OpenWeaponMenu(ply, WEAPON_MELEE)
	end
end)
net.Receive("SendMeleeWeapon", function(len, ply)
	local WeaponID = net.ReadString()
	local Weapon = WeaponManager:FindWeaponByWeaponId(WeaponID, WEAPON_MELEE)
	local ShouldSaveWeapon = false
	if net.ReadBool() then
		ShouldSaveWeapon = net.ReadTable().ShouldSaveWeapon.Value
	end

	if ShouldSaveWeapon then
		ply:SetMeleeWeapon(Weapon)
	elseif !ply:GetMeleeWeaponGiven() then
		ply:GiveWeapon(Weapon)
		ply:SetMeleeWeaponGiven(true)
	end

	if !ShouldSaveWeapon then
		ply:SetMeleeWeapon(nil)
	end

	if !ply:GetPrimaryWeaponGiven() then
		WeaponManager:OpenWeaponMenu(ply, WEAPON_PRIMARY)
	elseif !ply:GetSecondaryWeaponGiven() then
		WeaponManager:OpenWeaponMenu(ply, WEAPON_SECONDARY)
	end
end)
net.Receive("RequestPrimaryWeaponMenu", function(len, ply)
	WeaponManager:OpenWeaponMenu(ply, WEAPON_PRIMARY)
end)
net.Receive("RequestSecondaryWeaponMenu", function(len, ply)
	WeaponManager:OpenWeaponMenu(ply, WEAPON_SECONDARY)
end)
net.Receive("RequestMeleeWeaponMenu", function(len, ply)
	WeaponManager:OpenWeaponMenu(ply, WEAPON_MELEE)
end)

Commands:AddCommand({"weapons", "primaryweapon"}, "Open primary weapons menu.", function(ply, args)
	WeaponManager:OpenWeaponMenu(ply, WEAPON_PRIMARY)
end)
Commands:AddCommand("secondaryweapon", "Open secondary weapons menu.", function(ply, args)
	WeaponManager:OpenWeaponMenu(ply, WEAPON_SECONDARY)
end)
Commands:AddCommand("meleeweapon", "Open melee weapons menu.", function(ply, args)
	WeaponManager:OpenWeaponMenu(ply, WEAPON_MELEE)
end)

util.AddNetworkString("RequestPrimaryWeaponMenu")
util.AddNetworkString("RequestSecondaryWeaponMenu")
util.AddNetworkString("RequestMeleeWeaponMenu")
util.AddNetworkString("SendPrimaryWeapon")
util.AddNetworkString("SendSecondaryWeapon")
util.AddNetworkString("SendMeleeWeapon")