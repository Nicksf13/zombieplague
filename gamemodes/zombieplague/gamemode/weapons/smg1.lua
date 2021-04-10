Weapon.PrettyName = "SMG1"
Weapon.WeaponID = "weapon_smg1"
Weapon.DamageMultiplier = 1
Weapon.WeaponType = WEAPON_PRIMARY
function Weapon:GiveWeapon(ply)
    local Weap = ply:Give(self.WeaponID)
    ply:GiveAmmo(Weap:GetMaxClip1() * 10, Weap:GetPrimaryAmmoType(), true) 
    ply:GiveAmmo(1, Weap:GetSecondaryAmmoType(), true) 
end