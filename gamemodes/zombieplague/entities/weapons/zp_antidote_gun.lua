SWEP.PrintName		= "Antidote gun"		-- 'Nice' Weapon name (Shown on HUD)
SWEP.Author			= ""
SWEP.Contact		= ""
SWEP.Purpose		= ""
SWEP.Instructions	= ""

SWEP.ViewModelFOV	= 62
SWEP.ViewModelFlip	= false
SWEP.ViewModel		= "models/weapons/v_pistol.mdl"
SWEP.WorldModel		= "models/weapons/w_357.mdl"

SWEP.Spawnable			= false
SWEP.AdminOnly			= false

SWEP.Primary.ClipSize		= 8					-- Size of a clip
SWEP.Primary.DefaultClip	= 32				-- Default number of bullets in a clip
SWEP.Primary.Automatic		= false				-- Automatic/Semi Auto
SWEP.Primary.Ammo			= "Pistol"

SWEP.Secondary.ClipSize		= -1				-- Size of a clip
SWEP.Secondary.DefaultClip	= -1				-- Default number of bullets in a clip
SWEP.Secondary.Automatic	= false				-- Automatic/Semi Auto
SWEP.Secondary.Ammo			= "Pistol"



--[[---------------------------------------------------------
   Name: SWEP:Initialize( )
   Desc: Called when the weapon is first loaded
-----------------------------------------------------------]]
function SWEP:Initialize()
	self:SetHoldType( "pistol" )
end
function SWEP:PrimaryAttack()
	if ( IsFirstTimePredicted() ) then
		local bullet = {}
		bullet.Num = 1
		bullet.Src = self.Owner:GetShootPos()
		bullet.Dir = self.Owner:GetAimVector()
		bullet.Spread = Vector( 0.01, 0.01, 0 )
		bullet.Tracer = 1
		bullet.Force = 5
		bullet.Damage = 0
		function bullet:Callback(attacker, tr, dmginfo)
		
		end
		self.Owner:FireBullets( bullet )

		self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
		self.Owner:SetAnimation( PLAYER_ATTACK1 )
	
	end
end
function SWEP:SecondaryAttack()
end
