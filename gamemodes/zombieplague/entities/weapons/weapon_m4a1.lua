SWEP.Base = "weapon_base"
SWEP.PrintName	= "M4A1"
SWEP.Category = "JG 4 Rifles"
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.AutoSwitchTo = true
SWEP.AutoSwitchFrom = true
SWEP.Author	= "JohnnieGun"	
SWEP.Instructions = "test"
SWEP.Weight = 5
SWEP.Slot = 3
SWEP.SlotPos = 3
SWEP.DrawCrosshair = true
SWEP.DrawAmmo = true
SWEP.BounceWeaponIcon = false --los
SWEP.DrawWeaponInfoBox = true
SWEP.IconLetter	= "w"
--ttf = "cs" --old
--ttf = "Counter-Strike" -- new

if ( CLIENT ) then       
	killicon.AddFont( "weapon_m4a1", "CSKillIcons", "w", Color( 255, 80, 0, 255 ) )
	surface.CreateFont("CSKillIcons", { font="csd", weight="500", size=ScreenScale(30),antialiasing=true,additive=true })
	surface.CreateFont("CSSelectIcons", { font="csd", weight="500", size=ScreenScale(60),antialiasing=true,additive=true })
end

SWEP.HoldType = "ar2"
SWEP.ViewModelFlip = false
SWEP.UseHands = true
SWEP.ViewModel = "models/weapons/cstrike/c_rif_m4a1.mdl"
SWEP.WorldModel = "models/weapons/w_rif_m4a1.mdl" --"models/weapons/w_rif_m4a1_silencer.mdl"
SWEP.Primary.Sound = Sound("Weapon_M4A1.Single")

SWEP.Primary.Spread = 0.035

SWEP.Primary.Delay = 0.09
SWEP.Primary.Recoil_pitch = -0.5
SWEP.Primary.Recoil_yaw_min = 0
SWEP.Primary.Recoil_yaw_max = 0
SWEP.Primary.Recoil_roll = 0

SWEP.Primary.Damage = 31
SWEP.Primary.NPCDamage = 31
SWEP.Primary.NumberofShots = 1
SWEP.Primary.TakeAmmo = 1
SWEP.Primary.ClipSize = 30
SWEP.Primary.DefaultClip = 30
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "AR2"
SWEP.CSMuzzleFlashes = 1
SWEP.Scope = 0
SWEP.ReloadTimer = CurTime()

-- Доп атака(глушитель)
SWEP.Secondary.ClipSize	= 0
SWEP.Secondary.DefaultClip = 0
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"
SWEP.Secondary.Delay	= 0.25


SWEP.Silencer = 0
SWEP.SilencerTimer = CurTime()
SWEP.ReloadingTimer = CurTime()

function SWEP:TranslateFOV( fov )
	self.ViewModelFOV = self.Owner:GetInfo("viewmodel_fov")
	return self.ViewModelFOV
end

function SWEP:SetupDataTables()
	self:NetworkVar("Float", 0, "Silencer")

	if self.ExtraDataTables then
		self.ExtraDataTables(self)
	end
end

function SWEP:Initialize()
	self:SetWeaponHoldType( self.HoldType )
	self:SetSilencer(0)
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
	if self:GetSilencer() == 2 then 
	self:EmitSound(Sound("Weapon_USP.SilencedShot"))
	elseif self:GetSilencer() == 0 then 
	self:EmitSound(Sound(self.Primary.Sound))
	end
	self.Owner:ViewPunchReset()
	self.Owner:ViewPunch( Angle( self.Primary.Recoil_pitch,math.Rand(self.Primary.Recoil_yaw_min,self.Primary.Recoil_yaw_max),self.Primary.Recoil_roll ) ) 
	self:TakePrimaryAmmo(self.Primary.TakeAmmo)
	if self:GetSilencer() == 2 then
	self.Weapon:SendWeaponAnim(ACT_VM_PRIMARYATTACK_SILENCED)
	elseif self:GetSilencer() == 0 then
	self.Weapon:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
	end
	if self:GetSilencer() == 2 and self.Weapon:Clip1() == 0 then
		self.Weapon:SendWeaponAnim( ACT_VM_DRYFIRE_SILENCED )
	elseif self:GetSilencer() == 0 and self.Weapon:Clip1() == 0 then
		self.Weapon:SendWeaponAnim( ACT_VM_DRYFIRE )
	end
	self.Owner:SetAnimation( PLAYER_ATTACK1 )
	self:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
	self.ReloadingTimer = CurTime() + self.Primary.Delay
	
	
end



function SWEP:SecondaryAttack()
	if self:GetSilencer() == 0 then
		--self:EmitSound( Sound("Weapon_USP.AttachSilencer"))
		self:SetSilencer(1)
		self.Weapon:SendWeaponAnim( ACT_VM_ATTACH_SILENCER )
		self.Primary.Damage = 27
		self.Primary.Spread = 0.025
		--self.WorldModel = "models/weapons/w_rif_m4a1_silencer.mdl"
		self:SetNextPrimaryFire( CurTime() + self.Owner:GetViewModel():SequenceDuration() )
		self:SetNextSecondaryFire( CurTime() + self.Owner:GetViewModel():SequenceDuration() )
		self.SilencerTimer = CurTime() + self.Owner:GetViewModel():SequenceDuration()
		self.ReloadingTimer = CurTime() + self.Owner:GetViewModel():SequenceDuration()
	elseif self:GetSilencer() == 2 then
		--self:EmitSound( Sound("Weapon_USP.DetachSilencer"))
		self:SetSilencer(3)
		self.Weapon:SendWeaponAnim( ACT_VM_DETACH_SILENCER )
		self.Primary.Damage = 31
		self.Primary.Spread = 0.035
		--self.WorldModel = "models/weapons/w_rif_m4a1.mdl"
		self:SetNextPrimaryFire( CurTime() + self.Owner:GetViewModel():SequenceDuration() )
		self:SetNextSecondaryFire( CurTime() + self.Owner:GetViewModel():SequenceDuration() )
		self.SilencerTimer = CurTime() + self.Owner:GetViewModel():SequenceDuration()
		self.ReloadingTimer = CurTime() + self.Owner:GetViewModel():SequenceDuration()		
end
end

function SWEP:Deploy()
	if self:GetSilencer() >= 2 then
		self.Weapon:SendWeaponAnim( ACT_VM_DRAW_SILENCED)
	elseif self:GetSilencer() == 0 then
		self.Weapon:SendWeaponAnim( ACT_VM_DRAW )
	end
	self:SetNextPrimaryFire( CurTime() + self.Owner:GetViewModel():SequenceDuration() )
	self:SetNextSecondaryFire( CurTime() + self.Owner:GetViewModel():SequenceDuration() )	
	self:SetWeaponHoldType( self.HoldType )
	self.SilencerTimer = CurTime()
	if self:GetSilencer() == 1 then
	self:SetSilencer(0)
	elseif self:GetSilencer() == 3 then
	self:SetSilencer(2)
	end
	return true	
end

function SWEP:Holster()
if self:GetSilencer() == 1 then
self:SetSilencer(0)
self.Primary.Damage = 31
self.Primary.Spread = 0.035
end
if self:GetSilencer() == 3 then
self:GetSilencer(2)
self.Primary.Damage = 27
self.Primary.Spread = 0.025
end
self.SilencerTimer = CurTime()
self.ReloadingTimer = CurTime()
return true
end


function SWEP:Reload()
if self.ReloadingTimer <= CurTime() then
if self:GetSilencer() == 2 then
self:DefaultReload(ACT_VM_RELOAD_SILENCED)
elseif self:GetSilencer() == 0 then
self:DefaultReload(ACT_VM_RELOAD)
end
end
end

function SWEP:Equip()
		self:SetHoldType(self.HoldType)
end

function SWEP:Think()
if self.SilencerTimer <= CurTime() then
if self:GetSilencer() == 1 then
self:SetSilencer(2)
elseif self:GetSilencer() == 3 then
self:SetSilencer(0)
end
if self:GetSilencer() == 2 then
self.WorldModel = "models/weapons/w_rif_m4a1_silencer.mdl"
elseif self:GetSilencer() == 0 then
self.WorldModel = "models/weapons/w_rif_m4a1.mdl"
end
end
end

function SWEP:DrawWeaponSelection( x, y, wide, tall, alpha )
	draw.SimpleText( self.IconLetter, "CSSelectIcons", x + wide/2, y + tall*0.2, Color( 255, 210, 0, 255 ), TEXT_ALIGN_CENTER )
end