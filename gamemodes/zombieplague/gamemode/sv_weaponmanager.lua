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
	local Files = file.Find("zombieplague/gamemode/weapons/*.lua", "LUA")
	for k, File in pairs(Files) do
		Weapon = WeaponManager:CreateNewWeapon()

		include("zombieplague/gamemode/weapons/" .. File)
		
		if Weapon:ShouldBeEnabled() && WeaponManager:ServerHasWeapon(Weapon.WeaponID) then
			if !Weapon.PrettyName then
				print("Cannot load: '" .. File .. "', unknown 'Pretty Name'!")
			elseif !Weapon.WeaponID then
				print("Cannot load: '" .. File .. "', unknown 'WeaponID'!")
			elseif WeaponManager:IsValidWeaponType(Weapon.WeaponType) then
				self:AddWeapon(Weapon, Weapon.WeaponType)
			else
				print("Invalid weapon type!")
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
		local Weap = ply:Give(self.WeaponID)
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
	table.insert(self:GetWeaponsTableByWeaponType(WeaponType), Weapon)

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
function WeaponManager:GetWeaponsTableByWeaponType(WeaponType)
	if WeaponType == WEAPON_PRIMARY then
		return self.PrimaryWeapons
	elseif WeaponType == WEAPON_SECONDARY then
		return self.SecondaryWeapons
	else
		return self.MeleeWeapons
	end
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
function WeaponManager:OpenWeaponMenu(ply, WeaponType)
	local PrettyWeapons = {}
	for k, Weapon in pairs(self:GetWeaponsTableByWeaponType(WeaponType)) do
		PrettyWeapons[Weapon.WeaponID] = {
			Description = Weapon.PrettyName,
			Order = Weapon.Order
		}
	end

	return PrettyWeapons
end
function WeaponManager:OpenPrimaryWeaponMenu(ply)
	net.Start("OpenBackMenu")
		net.WriteString("SendPrimaryWeapon")
		net.WriteTable(WeaponManager:OpenWeaponMenu(ply, WEAPON_PRIMARY))
	net.Send(ply)
end
function WeaponManager:OpenSecondaryWeaponMenu(ply)
	net.Start("OpenBackMenu")
		net.WriteString("SendSecondaryWeapon")
		net.WriteTable(WeaponManager:OpenWeaponMenu(ply, WEAPON_SECONDARY))
	net.Send(ply)
end
function WeaponManager:OpenMeleeWeaponMenu(ply)
	net.Start("OpenBackMenu")
		net.WriteString("SendMeleeWeapon")
		net.WriteTable(WeaponManager:OpenWeaponMenu(ply, WEAPON_MELEE))
	net.Send(ply)
end
net.Receive("SendPrimaryWeapon", function(len, ply)
	ply:SetPrimaryWeapon(nil)
	ply:SetSecondaryWeapon(nil)
	ply:SetMeleeWeapon(nil)

	ply:SetPrimaryWeapon(WeaponManager:FindWeaponByWeaponId(net.ReadString(), WEAPON_PRIMARY))
end)
net.Receive("SendSecondaryWeapon", function(len, ply)
	ply:SetSecondaryWeapon(WeaponManager:FindWeaponByWeaponId(net.ReadString(), WEAPON_SECONDARY))
end)
net.Receive("SendMeleeWeapon", function(len, ply)
	ply:SetMeleeWeapon(WeaponManager:FindWeaponByWeaponId(net.ReadString(), WEAPON_MELEE))
end)
net.Receive("RequestWeaponMenu", function(len, ply)
	WeaponManager:OpenPrimaryWeaponMenu(ply)
end)

Commands:AddCommand("weapons", "Open the weapons menu.", function(ply, args)
	WeaponManager:OpenPrimaryWeaponMenu(ply)
end)

util.AddNetworkString("RequestWeaponMenu")
util.AddNetworkString("SendPrimaryWeapon")
util.AddNetworkString("SendSecondaryWeapon")
util.AddNetworkString("SendMeleeWeapon")