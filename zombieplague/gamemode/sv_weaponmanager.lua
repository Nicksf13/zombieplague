WeaponManager = {PrimaryWeapons = {}, SecondaryWeapons = {}}

function WeaponManager:SearchWeapons()
	local Files = file.Find("zombieplague/gamemode/weapons/*.lua", "LUA")
	for k, File in pairs(Files) do
		Weapon = {}
		Weapon.PrimaryWeapon = true
		function Weapon:GiveWeapon(ply)
			Weap = ply:Give(self.WeaponID)
			ply:GiveAmmo((Weap:GetMaxClip1() or Weap:GetMaxClip2()) * 10, Weap:GetPrimaryAmmoType(), true) 
		end
		include("zombieplague/gamemode/weapons/" .. File)
		
		if Weapon.PrettyName == nil then
			print("Cannot not load: '" .. File .. "', unknown 'Pretty Name'!")
		elseif Weapon.WeaponID == nil then
			print("Cannot not load: '" .. File .. "', unknown 'WeaponID'!")
		elseif Weapon.PrimaryWeapon then
			WeaponManager:AddPrimaryWeapon(Weapon)
		else
			WeaponManager:AddSecondaryWeapon(Weapon)
		end
	end
end
function WeaponManager:GetWeaponMultiplier(Weapon)
	for k, Weap in pairs(self.GetPrimaryWeapons()) do
		if Weap.WeaponID == Weapon then
			return Weap.DamageMultiplier
		end
	end
	for k, Weap in pairs(self.GetSecondaryWeapons()) do
		if Weap.WeaponID == Weapon then
			return Weap.DamageMultiplier
		end
	end
	
	return nil
end
function WeaponManager:AddPrimaryWeapon(Weapon)
	table.insert(WeaponManager.PrimaryWeapons, Weapon)
end
function WeaponManager:AddSecondaryWeapon(Weapon)
	table.insert(WeaponManager.SecondaryWeapons, Weapon)
end
function WeaponManager:GetPrimaryWeapons()
	return WeaponManager.PrimaryWeapons
end
function WeaponManager:GetSecondaryWeapons()
	return WeaponManager.SecondaryWeapons
end
function WeaponManager:OpenPrimaryWeaponMenu(ply)
	ply:SetPrimaryWeapon(nil)
	ply:SetSecondaryWeapon(nil)
	local PrettyWeapons = {}
	for k, Weap in pairs(WeaponManager:GetPrimaryWeapons()) do
		table.insert(PrettyWeapons, Weap.PrettyName)
	end
	
	net.Start("OpenBackMenu")
		net.WriteString("SendPrimaryWeapon")
		net.WriteTable(PrettyWeapons)
	net.Send(ply)
end
function WeaponManager:OpenSecondaryWeaponMenu(ply)
	local PrettyWeapons = {}
	for k, Weap in pairs(WeaponManager:GetSecondaryWeapons()) do
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

hook.Add("PlayerSay", "ZPWeapons", function(ply, txt)
	if txt == "/weapons" then
		WeaponManager:OpenPrimaryWeaponMenu(ply)
	end
end)
net.Receive("RequestWeaponMenu", function(len, ply)
	WeaponManager:OpenPrimaryWeaponMenu(ply)
end)

util.AddNetworkString("RequestWeaponMenu")
util.AddNetworkString("SendPrimaryWeapon")
util.AddNetworkString("SendSecondaryWeapon")
util.AddNetworkString("OpenPrimaryWeaponMenu")
util.AddNetworkString("OpenSecondaryWeaponMenu")