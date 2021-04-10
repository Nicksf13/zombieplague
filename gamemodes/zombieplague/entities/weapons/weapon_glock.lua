SWEP.Base = "weapon_base"
SWEP.PrintName	= "Glock 18"
SWEP.Category = "JG 1 Pistols"
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.AutoSwitchTo = true
SWEP.AutoSwitchFrom = true
SWEP.Author	= "JohnnieGun"	
SWEP.Instructions = "test"
SWEP.Weight = 5
SWEP.Slot = 1
SWEP.SlotPos = 3
SWEP.DrawCrosshair = true
SWEP.DrawAmmo = true
SWEP.BounceWeaponIcon = false --los
SWEP.DrawWeaponInfoBox = true
SWEP.IconLetter	= "c"
--ttf = "cs" --old
--ttf = "Counter-Strike" -- new

if ( CLIENT ) then       
	killicon.AddFont( "weapon_glock", "CSKillIcons", "c", Color( 255, 80, 0, 255 ) )
	surface.CreateFont("CSKillIcons", { font="csd", weight="500", size=ScreenScale(30),antialiasing=true,additive=true })
	surface.CreateFont("CSSelectIcons", { font="csd", weight="500", size=ScreenScale(60),antialiasing=true,additive=true })
end

SWEP.HoldType = "pistol"
SWEP.ViewModelFlip = false
SWEP.UseHands = true
SWEP.ViewModel = "models/weapons/cstrike/c_pist_glock18.mdl"
SWEP.WorldModel = "models/weapons/w_pist_glock18.mdl"
SWEP.Primary.Sound = Sound("Weapon_Glock.Single")

SWEP.Primary.Spread = 0.02

SWEP.Primary.Delay = 0.15
SWEP.Primary.Recoil_pitch = -0.3
SWEP.Primary.Recoil_yaw_min = 0
SWEP.Primary.Recoil_yaw_max = 0
SWEP.Primary.Recoil_roll = 0

SWEP.Primary.Damage = 28
SWEP.Primary.NPCDamage = 28
SWEP.Primary.NumberofShots = 1
SWEP.Primary.TakeAmmo = 1
SWEP.Primary.ClipSize = 20
SWEP.Primary.DefaultClip = 20
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "Pistol"
SWEP.CSMuzzleFlashes = 1
SWEP.Scope = 0
SWEP.ReloadTimer = CurTime()

-- Доп атака(режим стрельбы)
SWEP.Secondary.Sound = "weapons/glock/glock_sliderelease.wav"
SWEP.Secondary.ClipSize	= 0
SWEP.Secondary.DefaultClip = 0
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"
SWEP.Secondary.Delay	= 0.5

SWEP.Burst = 0
SWEP.BurstTimer = CurTime()
SWEP.Primary.DelayAlt = 0.5
SWEP.Reloading = 0
SWEP.ReloadingTimer = CurTime()
SWEP.Tracer = 0

function SWEP:TranslateFOV( fov )
	self.ViewModelFOV = self.Owner:GetInfo("viewmodel_fov")
	return self.ViewModelFOV
end

function SWEP:SetupDataTables()
	self:NetworkVar("Bool", 0, "Auto")

	if self.ExtraDataTables then
		self.ExtraDataTables(self)
	end
end

function SWEP:Initialize()
	self:SetWeaponHoldType( self.HoldType )
	self:SetAuto(false)
	
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
	--self.Owner:ViewPunch( Angle( self.Primary.Recoil_pitch,math.Rand(self.Primary.Recoil_yaw_min,self.Primary.Recoil_yaw_max),self.Primary.Recoil_roll ) ) 
	self:TakePrimaryAmmo(self.Primary.TakeAmmo)
	self.Weapon:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
	self.Owner:SetAnimation( PLAYER_ATTACK1 )	
	self:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
	self.ReloadingTimer = CurTime() + self.Primary.Delay
	
	if self:GetAuto() == false then
	self.Primary.Delay = 0.15
	self:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
	self:SetNextSecondaryFire( CurTime() + self.Primary.Delay )
	self.Primary.Automatic = false
	self.Primary.Spread = 0.02
	self.Owner:ViewPunch( Angle( self.Primary.Recoil_pitch,math.Rand(self.Primary.Recoil_yaw_min,self.Primary.Recoil_yaw_max),self.Primary.Recoil_roll ) ) 
	
	elseif self:GetAuto() == true then
	self.Primary.Delay = 0.06
	self:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
	self:SetNextSecondaryFire( CurTime() + self.Primary.Delay )
	self.Primary.Automatic = true
	self.Primary.Spread = 0.07
	self.Owner:ViewPunch( Angle( -0.7,math.Rand(self.Primary.Recoil_yaw_min,self.Primary.Recoil_yaw_max),self.Primary.Recoil_roll ) ) 
end
end

function SWEP:SecondaryAttack()
self:EmitSound( Sound(self.Secondary.Sound) )
if self:GetAuto() == false then
self:SetNextSecondaryFire( CurTime() + self.Secondary.Delay )
self:SetAuto(true)

elseif self:GetAuto() == true then
self:SetNextSecondaryFire( CurTime() + self.Secondary.Delay )
self:SetAuto(false)
end
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
	draw.SimpleText( self.IconLetter, "CSSelectIcons", x + wide/2, y + tall*0.2, Color( 255, 210, 0, 255 ), TEXT_ALIGN_CENTER )
end
