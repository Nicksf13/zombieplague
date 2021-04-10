SWEP.Base = "weapon_base"
SWEP.PrintName	= "M3"
SWEP.Category = "JG 2 Shotguns"
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
SWEP.IconLetter	= "k"
--ttf = "cs" --old
--ttf = "Counter-Strike" -- new

if ( CLIENT ) then       
	killicon.AddFont( "weapon_m3super90", "CSKillIcons", "k", Color( 255, 80, 0, 255 ) )
	surface.CreateFont("CSKillIcons", { font="csd", weight="500", size=ScreenScale(30),antialiasing=true,additive=true })
	surface.CreateFont("CSSelectIcons", { font="csd", weight="500", size=ScreenScale(60),antialiasing=true,additive=true })
end

SWEP.HoldType = "shotgun"
SWEP.ViewModelFlip = false
SWEP.UseHands = true
SWEP.ViewModel = "models/weapons/cstrike/c_shot_m3super90.mdl"
SWEP.WorldModel = "models/weapons/w_shot_m3super90.mdl"
SWEP.Primary.Sound = Sound("Weapon_M3.Single")

SWEP.Primary.Spread = 0.07

SWEP.Primary.Delay = 0.88
SWEP.Primary.Recoil_pitch = -1.5
SWEP.Primary.Recoil_yaw_min = 0
SWEP.Primary.Recoil_yaw_max = 0
SWEP.Primary.Recoil_roll = 0

SWEP.Primary.Damage = 26
SWEP.Primary.NPCDamage = 26
SWEP.Primary.NumberofShots = 9
SWEP.Primary.TakeAmmo = 1
SWEP.Primary.ClipSize = 8
SWEP.Primary.DefaultClip = 8
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "Buckshot"
SWEP.CSMuzzleFlashes = 1

-- Доп атака(нет)
SWEP.Secondary.ClipSize	= 0
SWEP.Secondary.DefaultClip = 0
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"
SWEP.Secondary.Delay	= 0.25	

SWEP.ShotTimer = CurTime()
SWEP.Reloading = 0
SWEP.ReloadingTimer = CurTime()
SWEP.ReloadingInsert = 0
SWEP.ReloadingInsertTimer = CurTime()

function SWEP:TranslateFOV( fov )
	self.ViewModelFOV = self.Owner:GetInfo("viewmodel_fov")
	return self.ViewModelFOV
end

function SWEP:SetupDataTables()
	self:NetworkVar("Bool", 1, "Reloading")
	self:NetworkVar("Float", 3, "ReloadTime")
	self:NetworkVar("Float", 4, "NextIdle")

	if self.ExtraDataTables then
		self.ExtraDataTables(self)
	end
end

function SWEP:Initialize()
	self:SetWeaponHoldType( self.HoldType )
	self:SetReloading(false)
	
end

function SWEP:PrimaryAttack()
	if ( !self:CanPrimaryAttack() ) then return end
	self:SetReloading( false )
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
	
end

function SWEP:SecondaryAttack()
end

function SWEP:Deploy()
	self.Weapon:SendWeaponAnim( ACT_VM_DRAW )
	self:SetNextPrimaryFire( CurTime() + self.Owner:GetViewModel():SequenceDuration() )	
	self:SetWeaponHoldType( self.HoldType )
	
	return true
end

function SWEP:Holster()
self:SetReloading( false )
return true
end


function SWEP:Reload()
	if not self:CanReload() then return end

	self:PlayAnim( ACT_SHOTGUN_RELOAD_START )
	self.Owner:DoReloadEvent()

	self:SetReloading( true )
	self:SetReloadTime( CurTime() + self.Owner:GetViewModel():SequenceDuration() )

	if self.ReloadSound then
		self:EmitSound(self.ReloadSound)
	end
end

function SWEP:InsertShell()
	self:SetClip1( self:Clip1() + 1 )
	self.Owner:RemoveAmmo( 1, self:GetPrimaryAmmoType() )

	self:PlayAnim( ACT_VM_RELOAD )

	self:SetReloadTime( CurTime() + self.Owner:GetViewModel():SequenceDuration() )

	if self.ReloadShellSound then
		self:EmitSound(self.ReloadShellSound)
	end
end

function SWEP:ReloadThink()
	if self:GetReloadTime() > CurTime() then return end

	if self:Clip1() < self.Primary.ClipSize and self.Owner:GetAmmoCount( self:GetPrimaryAmmoType() ) > 0
		and not self.Owner:KeyDown( IN_ATTACK ) then
		self:InsertShell()
	else
		self:FinishReload()
	end
end

function SWEP:FinishReload()
	self:SetReloading( false )

	self:PlayAnim( ACT_SHOTGUN_RELOAD_FINISH )
	self:SetReloadTime( CurTime() + self.Owner:GetViewModel():SequenceDuration() )
	self:SetNextPrimaryFire( CurTime() + self.Owner:GetViewModel():SequenceDuration() )

	if self.PumpSound then self:EmitSound( self.PumpSound ) end
end

function SWEP:Equip()
		self:SetHoldType(self.HoldType)
end

function SWEP:Think()
if self:GetReloading() then self:ReloadThink() end
	if self.Weapon:Clip1() <= 0 then
	self:Reload()
	end
end
 

function SWEP:DrawWeaponSelection( x, y, wide, tall, alpha )
	draw.SimpleText( self.IconLetter, "CSSelectIcons", x + wide/2, y + tall*0.3, Color( 255, 210, 0, 255 ), TEXT_ALIGN_CENTER )
end

function SWEP:PlayAnim(act)
	local vmodel = self.Owner:GetViewModel()
	local seq = vmodel:SelectWeightedSequence(act)

	vmodel:SendViewModelMatchingSequence(seq)
end

function SWEP:QueueIdle()
	self:SetNextIdle( CurTime() + self.Owner:GetViewModel():SequenceDuration() + 0.1 )
end

function SWEP:CanReload()
	return self:Ammo1() > 0 and self:Clip1() < self.Primary.ClipSize
		and not self:GetReloading() and self:GetNextPrimaryFire() < CurTime() 
end
