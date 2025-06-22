Weapon.PrettyName = "SMG1"
Weapon.WeaponID = "weapon_smg1"
Weapon.DamageMultiplier = 1
Weapon.WeaponType = WEAPON_PRIMARY
function Weapon:GiveWeapon(ply)
    local Weap = ply:GetWeapon(self.WeaponID)

    if !IsValid(Weap) then
        Weap = ply:Give(self.WeaponID)
    end

    ply:GiveAmmo(Weap:GetMaxClip1() * 10, Weap:GetPrimaryAmmoType(), true) 
    ply:GiveAmmo(2, Weap:GetSecondaryAmmoType(), true) 
end