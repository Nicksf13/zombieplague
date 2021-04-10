SWEP.Base = "weapon_base"
SWEP.PrintName	= "G3SG1"
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
SWEP.DrawCrosshair = false
SWEP.DrawAmmo = true
SWEP.BounceWeaponIcon = false --los
SWEP.DrawWeaponInfoBox = true
SWEP.IconLetter	= "i"
--ttf = "cs" --old
--ttf = "Counter-Strike" -- new

if ( CLIENT ) then       
	killicon.AddFont( "weapon_g3sg1", "CSKillIcons", "i", Color( 255, 80, 0, 255 ) )
	surface.CreateFont("CSKillIcons", { font="csd", weight="500", size=ScreenScale(30),antialiasing=true,additive=true })
	surface.CreateFont("CSSelectIcons", { font="csd", weight="500", size=ScreenScale(60),antialiasing=true,additive=true })
end

SWEP.HoldType = "ar2"
SWEP.ViewModelFlip = false
SWEP.UseHands = true
SWEP.ViewModel = "models/weapons/cstrike/c_snip_g3sg1.mdl"
SWEP.WorldModel = "models/weapons/w_snip_g3sg1.mdl"
SWEP.Primary.Sound = Sound("Weapon_G3SG1.Single")

SWEP.Primary.Spread = 0.04

SWEP.Primary.Delay = 0.25
SWEP.Primary.Recoil_pitch = -0.3
SWEP.Primary.Recoil_yaw_min = 0
SWEP.Primary.Recoil_yaw_max = 0
SWEP.Primary.Recoil_roll = 0

SWEP.Primary.Damage = 79
SWEP.Primary.NPCDamage = 79
SWEP.Primary.NumberofShots = 1
SWEP.Primary.TakeAmmo = 1
SWEP.Primary.ClipSize = 20
SWEP.Primary.DefaultClip = 20
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "357"
SWEP.CSMuzzleFlashes = 1
SWEP.Scope = 0

-- Доп атака(оптический прицел)
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
	self:NetworkVar( "Float", 0, "Scoped" )
	self:NetworkVar( "Float", 1, "MouseSensitivity" )
end

function SWEP:Initialize()
	self:SetWeaponHoldType( self.HoldType )
	self:SetScoped(0)
	self:SetMouseSensitivity(1)
end

function SWEP:PrimaryAttack()
	if ( !self:CanPrimaryAttack() ) then return end
	local bullet = {}
	if self:GetScoped() == 1 or self:GetScoped() == 2 then
	bullet.Tracer = 0
	self.Primary.Spread = 0.005
	else
	bullet.Tracer = self.Primary.Tracer
	self.Primary.Spread = 0.04
	end

	--local bullet = {}
	bullet.Num = self.Primary.NumberofShots
	bullet.Src = self.Owner:GetShootPos()
	bullet.Dir = self.Owner:GetAimVector()
	bullet.Spread = Vector( self.Primary.Spread, self.Primary.Spread, 0 )
	--bullet.Tracer = 0
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
	if self:GetScoped() == 0 then
		self.Owner:SetFOV( self.Owner:GetFOV() / 2, 0.22 )
		self:SetScoped(1)
		self:SetMouseSensitivity(0.5)
	elseif self:GetScoped() == 1 then
		self.Owner:SetFOV( self.Owner:GetFOV() / 4, 0.22 )
		self:SetScoped(2)
		self:SetMouseSensitivity(0.25)				
	elseif self:GetScoped() == 2 then
		self.Owner:SetFOV( 0, 0.22 )
		self:SetScoped(0)
		self:SetMouseSensitivity(1)
	end
end

function SWEP:Deploy()
	self.Weapon:SendWeaponAnim( ACT_VM_DRAW )			 -- Анимация от первого лица
	self:SetNextPrimaryFire( CurTime() + self.Owner:GetViewModel():SequenceDuration() )
	self:SetNextSecondaryFire( CurTime() + self.Owner:GetViewModel():SequenceDuration() )	
	self:SetScoped(0)
	self:SetMouseSensitivity(1)
	self.Primary.Spread = 0.04
	self:SetWeaponHoldType( self.HoldType )
	return true
end

function SWEP:Holster()
	self:SetScoped(0)
	self:SetMouseSensitivity(1)
	self.Owner:SetFOV( 0, 0.22 )
	self.Primary.Spread = 0.04
	return true
end

function SWEP:Reload()
	if self.ReloadingTimer <= CurTime() and self.Owner:GetAmmoCount(self.Primary.Ammo) > 0 and self.Owner:GetActiveWeapon():Clip1() < self.Primary.ClipSize then
		self:SetScoped(0)
		self:SetMouseSensitivity(1)
		self.Primary.Spread = 0.04
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

function SWEP:DrawHUD()
   if self:GetScoped() == 1 or self:GetScoped() == 2 then
		self.DrawCrosshair = false
		x, y = ScrW() / 2.0, ScrH() / 2.0 -- центр
		surface.SetDrawColor( 0, 0, 0, 255 )
		surface.DrawLine( x-150, y, x+150, y )	-- горизонталь
		surface.DrawLine( x, y-150, x, y+150 )	-- вертикаль
		surface.SetDrawColor( 255, 0, 0, 255 )
		surface.DrawLine( x-3, y, x+4, y )
		surface.DrawLine( x, y-3, x, y+4 )
		surface.DrawCircle( x, y, 150, 0, 0, 0, 255 )
		surface.DrawCircle( x, y, 151, 0, 0, 0, 255 )
	else
		self.DrawCrosshair = true
	end
end

function SWEP:AdjustMouseSensitivity()
return self:GetMouseSensitivity() || 1
end