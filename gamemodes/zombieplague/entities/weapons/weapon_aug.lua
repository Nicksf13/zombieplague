SWEP.Base = "weapon_base"
SWEP.PrintName	= "AUG"
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
SWEP.IconLetter	= "e"
--ttf = "cs" --old
--ttf = "Counter-Strike" -- new

if ( CLIENT ) then       
	killicon.AddFont( "weapon_aug", "CSKillIcons", "e", Color( 255, 80, 0, 255 ) )
	surface.CreateFont("CSKillIcons", { font="csd", weight="500", size=ScreenScale(30),antialiasing=true,additive=true })
	surface.CreateFont("CSSelectIcons", { font="csd", weight="500", size=ScreenScale(60),antialiasing=true,additive=true })
end

SWEP.HoldType = "smg"
SWEP.ViewModelFlip = false
SWEP.UseHands = true
SWEP.ViewModel = "models/weapons/cstrike/c_rif_aug.mdl"
SWEP.WorldModel = "models/weapons/w_rif_aug.mdl"
SWEP.Primary.Sound = Sound("Weapon_AUG.Single")

SWEP.Primary.Spread = 0.035

SWEP.Primary.Delay = 0.1
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

-- Доп атака(прицел)
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

function SWEP:SetupDataTables()
	self:NetworkVar( "Bool", 0, "Scoped" )
	self:NetworkVar( "Float", 1, "MouseSensitivity" )
end

function SWEP:Initialize()
	self:SetWeaponHoldType( self.HoldType )
	self:SetScoped(false)
	self:SetMouseSensitivity(1)
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
	self:EmitSound( Sound(self.Secondary.Sound) )
	self:SetNextSecondaryFire( CurTime() + self.Secondary.Delay )
	if self:GetScoped() == false then
		self.Primary.Spread = 0.02
		self.Primary.Delay = 0.14
		self.Owner:SetFOV( self.Owner:GetFOV() / 1.5, 0.22 )
		self:SetScoped(true)
		self:SetMouseSensitivity(0.66)
	elseif self:GetScoped() == true then
		self.Primary.Spread = 0.035
		self.Primary.Delay = 0.1
		self.Owner:SetFOV( 0, 0.22 )
		self:SetScoped(false)
		self:SetMouseSensitivity(1)
	end
end

function SWEP:Deploy()
	self.Weapon:SendWeaponAnim( ACT_VM_DRAW )
	self:SetNextPrimaryFire( CurTime() + self.Owner:GetViewModel():SequenceDuration() )	
	self:SetScoped(false)
	self:SetMouseSensitivity(1)
	self.Primary.Spread = 0.035
	self.Primary.Delay = 0.1
	self:SetWeaponHoldType( self.HoldType )
	return true
end

function SWEP:Holster()
	self:SetScoped(false)
	self:SetMouseSensitivity(1)
	self.Owner:SetFOV( 0, 0.22 )
	self.Primary.Spread = 0.035
	return true
end

function SWEP:Reload()
	if self.ReloadingTimer <= CurTime() and self.Owner:GetAmmoCount(self.Primary.Ammo) > 0 and self.Owner:GetActiveWeapon():Clip1() < self.Primary.ClipSize then
		self:SetScoped(false)
		self:SetMouseSensitivity(1)
		self.Primary.Spread = 0.035
		self.Primary.Delay = 0.1
		self.Owner:SetFOV( 0, 0.2 )
		self:DefaultReload(ACT_VM_RELOAD)
	end
end

function SWEP:Equip()
		self:SetHoldType(self.HoldType)
end

function SWEP:DrawWeaponSelection( x, y, wide, tall, alpha )
	draw.SimpleText( self.IconLetter, "CSSelectIcons", x + wide/2, y + tall*0.3, Color( 255, 210, 0, 255 ), TEXT_ALIGN_CENTER )
end


function SWEP:AdjustMouseSensitivity()
return self:GetMouseSensitivity() || 1
end