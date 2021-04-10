SWEP.Base = "weapon_base"
SWEP.PrintName	= "M249"
SWEP.Category = "JG 5 Machine Gun"
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.AutoSwitchTo = true
SWEP.AutoSwitchFrom = true
SWEP.Author	= "JohnnieGun"	
SWEP.Instructions = "test"
SWEP.Weight = 5
SWEP.Slot = 4
SWEP.SlotPos = 3
SWEP.DrawCrosshair = true
SWEP.DrawAmmo = true
SWEP.BounceWeaponIcon = false --los
SWEP.DrawWeaponInfoBox = true
SWEP.IconLetter	= "z"
--ttf = "cs" --old
--ttf = "Counter-Strike" -- new

if ( CLIENT ) then       
	killicon.AddFont( "weapon_m249", "CSKillIcons", "z", Color( 255, 80, 0, 255 ) )
	surface.CreateFont("CSKillIcons", { font="csd", weight="500", size=ScreenScale(30),antialiasing=true,additive=true })
	surface.CreateFont("CSSelectIcons", { font="csd", weight="500", size=ScreenScale(60),antialiasing=true,additive=true })
end

SWEP.HoldType = "ar2"
SWEP.ViewModelFlip = false
SWEP.UseHands = true
SWEP.ViewModel = "models/weapons/cstrike/c_mach_m249para.mdl"
SWEP.WorldModel = "models/weapons/w_mach_m249para.mdl"
SWEP.Primary.Sound = Sound("Weapon_M249.Single")

SWEP.Primary.Spread = 0.04

SWEP.Primary.Delay = 0.08
SWEP.Primary.Recoil_pitch = -0.6
SWEP.Primary.Recoil_yaw_min = 0
SWEP.Primary.Recoil_yaw_max = 0
SWEP.Primary.Recoil_roll = 0

SWEP.Primary.Damage = 35
SWEP.Primary.NPCDamage = 35
SWEP.Primary.NumberofShots = 1
SWEP.Primary.TakeAmmo = 1
SWEP.Primary.ClipSize = 100
SWEP.Primary.DefaultClip = 100
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "AR2"
SWEP.CSMuzzleFlashes = 1
SWEP.Scope = 0

-- Доп атака(зачем?)
SWEP.Secondary.Sound = Sound("Default.Zoom")
SWEP.Secondary.ClipSize	= 0
SWEP.Secondary.DefaultClip = 0
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"
SWEP.Secondary.Delay	= 0.25

SWEP.ReloadingTimer = CurTime()	

function SWEP:TranslateFOV( fov )
	self.ViewModelFOV = self.Owner:GetInfo("viewmodel_fov")
	return self.ViewModelFOV
end

function SWEP:Initialize()
	self:SetWeaponHoldType( self.HoldType )
end

function SWEP:PrimaryAttack()
	if ( !self:CanPrimaryAttack() ) then return end

	local bullet = {}
	bullet.Num = self.Primary.NumberofShots
	bullet.Src = self.Owner:GetShootPos()
	bullet.Dir = self.Owner:GetAimVector()
	bullet.Spread = Vector( self.Primary.Spread, self.Primary.Spread, 0 )
	bullet.Tracer = self.Primary.Tracer
	bullet.Force = self.Primary.Force
	bullet.Damage = self.Primary.Damage
	bullet.AmmoType = self.Primary.Ammo

	self:ShootEffects()
	self.Weapon:MuzzleFlash()
	self.Owner:FireBullets( bullet )
	self:EmitSound(Sound(self.Primary.Sound))
	self.Owner:ViewPunchReset()
	self.Owner:ViewPunch( Angle( self.Primary.Recoil_pitch,math.Rand(self.Primary.Recoil_yaw_min,self.Primary.Recoil_yaw_max),self.Primary.Recoil_roll ) ) 
	self:TakePrimaryAmmo(self.Primary.TakeAmmo)
	self.Weapon:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
	self.Owner:SetAnimation( PLAYER_ATTACK1 )
	self:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
	self.ReloadingTimer = CurTime() + self.Primary.Delay

end

function SWEP:SecondaryAttack()

end

function SWEP:Deploy()
	self.Weapon:SendWeaponAnim( ACT_VM_DRAW )
	self:SetNextPrimaryFire( CurTime() + self.Owner:GetViewModel():SequenceDuration() )	
	self:SetWeaponHoldType( self.HoldType )
	return true
end

function SWEP:Reload()
if self.ReloadingTimer <= CurTime() then
	self:DefaultReload(ACT_VM_RELOAD)
end
end

function SWEP:Equip()
		self:SetHoldType(self.HoldType)
end

function SWEP:DrawWeaponSelection( x, y, wide, tall, alpha )
	draw.SimpleText( self.IconLetter, "CSSelectIcons", x + wide/2, y + tall*0.3, Color( 255, 210, 0, 255 ), TEXT_ALIGN_CENTER )
end

