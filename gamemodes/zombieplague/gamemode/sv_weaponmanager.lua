WeaponManager = {PrimaryWeapons = {}, SecondaryWeapons = {}, WeaponsMultiplier = {}}

function WeaponManager:SearchWeapons()
	local Files = file.Find("zombieplague/gamemode/weapons/*.lua", "LUA")
	for k, File in pairs(Files) do
		Weapon = {}
		Weapon.PrimaryWeapon = true
		Weapon.DamageMultiplier = 1
		function Weapon:GiveWeapon(ply)
			Weap = ply:Give(self.WeaponID)
			if Weap:GetMaxClip1() then
				ply:GiveAmmo(Weap:GetMaxClip1() * 10, Weap:GetPrimaryAmmoType(), true) 
			else
				ply:GiveAmmo(Weap:GetMaxClip2() * 10, Weap:GetSecondaryAmmoType(), true) 
			end
		end
		function Weapon:ShouldBeEnabled()
			return true
		end
		include("zombieplague/gamemode/weapons/" .. File)
		
		if Weapon:ShouldBeEnabled() then
			if !Weapon.PrettyName then
				print("Cannot load: '" .. File .. "', unknown 'Pretty Name'!")
			elseif !Weapon.WeaponID then
				print("Cannot load: '" .. File .. "', unknown 'WeaponID'!")
			elseif Weapon.PrimaryWeapon then
				self:AddPrimaryWeapon(Weapon)
			else
				self:AddSecondaryWeapon(Weapon)
			end
		end
	end
end
function WeaponManager:GetWeaponMultiplier(Weapon)
	return self.WeaponsMultiplier[Weapon] and self.WeaponsMultiplier[Weapon] or 1
end
function WeaponManager:AddWeaponMultiplier(WeaponID, DamageMultiplier)
	self.WeaponsMultiplier[WeaponID] = DamageMultiplier
end
function WeaponManager:AddPrimaryWeapon(Weapon)
	table.insert(self.PrimaryWeapons, Weapon)
	self.WeaponsMultiplier[Weapon.WeaponID] = Weapon.DamageMultiplier
end
function WeaponManager:AddSecondaryWeapon(Weapon)
	table.insert(self.SecondaryWeapons, Weapon)
	self.WeaponsMultiplier[Weapon.WeaponID] = Weapon.DamageMultiplier
end
function WeaponManager:GetPrimaryWeapons()
	return self.PrimaryWeapons
end
function WeaponManager:GetSecondaryWeapons()
	return self.SecondaryWeapons
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
function WeaponManager:OpenPrimaryWeaponMenu(ply)
	ply:SetPrimaryWeapon(nil)
	ply:SetSecondaryWeapon(nil)
	local PrettyWeapons = {}
	for k, Weap in pairs(self:GetPrimaryWeapons()) do
		table.insert(PrettyWeapons, Weap.PrettyName)
	end
	
	net.Start("OpenBackMenu")
		net.WriteString("SendPrimaryWeapon")
		net.WriteTable(PrettyWeapons)
	net.Send(ply)
end
function WeaponManager:OpenSecondaryWeaponMenu(ply)
	local PrettyWeapons = {}
	for k, Weap in pairs(self:GetSecondaryWeapons()) do
		table.insert(PrettyWeapons, Weap.PrettyName)
	end
	
	net.Start("OpenBackMenu")
		net.WriteString("SendSecondaryWeapon")
		net.WriteTable(PrettyWeapons)
	net.Send(ply)
end

net.Receive("SendPrimaryWeapon", function(len, ply)
	ply:SetPrimaryWeapon(WeaponManager:GetPrimaryWeapons()[net.ReadInt(16)])
end)
net.Receive("SendSecondaryWeapon", function(len, ply)
	ply:SetSecondaryWeapon(WeaponManager:GetSecondaryWeapons()[net.ReadInt(16)])
end)
Commands:AddCommand("weapons", "Open the weapons menu.", function(ply, args)
	WeaponManager:OpenPrimaryWeaponMenu(ply)
end)
net.Receive("RequestWeaponMenu", function(len, ply)
	WeaponManager:OpenPrimaryWeaponMenu(ply)
end)

util.AddNetworkString("RequestWeaponMenu")
util.AddNetworkString("SendPrimaryWeapon")
util.AddNetworkString("SendSecondaryWeapon")
util.AddNetworkString("OpenPrimaryWeaponMenu")
util.AddNetworkString("OpenSecondaryWeaponMenu")