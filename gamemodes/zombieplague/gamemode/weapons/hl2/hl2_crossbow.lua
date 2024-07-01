Weapon.PrettyName = "Crossbow"
Weapon.WeaponID = "weapon_crossbow"
Weapon.DamageMultiplier = 2
Weapon.WeaponType = WEAPON_PRIMARY
Weapon.ProjectileID = "crossbow_bolt"
function Weapon:GiveWeapon(ply)
    local Weap = ply:Give(self.WeaponID)
    ply:GiveAmmo(Weap:GetMaxClip1() * 46, Weap:GetPrimaryAmmoType(), true)
end