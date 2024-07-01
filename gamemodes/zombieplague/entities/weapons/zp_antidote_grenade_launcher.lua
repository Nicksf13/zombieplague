SWEP.PrintName			= "Antitode Grenade Launcher"
SWEP.Author			= "The Fire Fuchs"
SWEP.Instructions		= "Cures an enemy"
SWEP.Base = "weapon_base"
SWEP.Spawnable = true
SWEP.AdminOnly = true
SWEP.UseHands = true
SWEP.DrawAmmo			= true
SWEP.DrawCrosshair		= true

SWEP.Primary.ClipSize		= 1
SWEP.Primary.DefaultClip	= 1
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo		= "GrenadeHL1"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo		= "none"

SWEP.Weight			= 5
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false

SWEP.Slot			= 5
SWEP.SlotPos			= 5

SWEP.ViewModel			= "models/weapons/c_smg1.mdl"
SWEP.WorldModel			= "models/weapons/w_smg1.mdl"

SWEP.ShootSound = Sound("weapons/crossbow/fire1.wav")
SWEP.AlternateSound = Sound("weapons/pistol/pistol_empty.wav")

function SWEP:Initialize()
	self:SetHoldType("smg")

	self.ProjectileMode = EXPLODE_ON_HIT_MODE
	self.ProjectileDelay = 5
end
function SWEP:PrimaryAttack()
	if not self:CanPrimaryAttack() then return end

	self:ShootGrenade()
	self.Weapon:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
	self.Owner:SetAnimation(PLAYER_ATTACK1)
	self.Owner:MuzzleFlash()

	if self:Clip1() == 0 then
		self:Reload()
	end
end

function SWEP:SecondaryAttack()
	self.ProjectileMode = (self.ProjectileMode + 1) % 3

	if CLIENT then
		self:EmitSound(self.AlternateSound)

		if self.ProjectileMode == EXPLODE_ON_HIT_MODE then
			notification.AddLegacy(Dictionary:GetPhrase("ZPGrenadeExplodeOnHit"), NOTIFY_GENERIC, 5)
		elseif self.ProjectileMode == ARM_ON_HIT_MODE then
			local FormatedString = string.format(Dictionary:GetPhrase("ZPGrenadeArmOnHit"), self.ProjectileDelay)
			notification.AddLegacy(FormatedString, NOTIFY_GENERIC, 5)
		elseif self.ProjectileMode == TIME_MODE then
			local FormatedString = string.format(Dictionary:GetPhrase("ZPGrenadeTimeMode"), self.ProjectileDelay)
			notification.AddLegacy(FormatedString, NOTIFY_GENERIC, 5)
		end
	end
end

function SWEP:Reload()
    if (self:Clip1() == self.Primary.ClipSize or self:GetOwner():GetAmmoCount(self.Primary.Ammo) <= 0) then return end
   	self:DefaultReload(ACT_VM_RELOAD)
    self:SetNextPrimaryFire(CurTime() + 1.5)
end

-- Thanks https://wiki.facepunch.com/gmod/Chair_Throwing_Gun
function SWEP:ShootGrenade()
	local Owner = self:GetOwner()

	if !Owner:IsValid() then return end

	if CLIENT then return end

	local Ent = ents.Create("zp_antidote_grenade")
	Ent:SetOwner(Owner)

	if !Ent:IsValid() then return end

	Ent:SetMode(self.ProjectileMode)
	Ent:SetExplosionDelay(self.ProjectileDelay)
	if self.ProjectileMode == TIME_MODE then
		Ent:Arm()
	end

	local Aimvec = Owner:GetAimVector()
	local Pos = Aimvec * 40
	Pos:Add(Owner:EyePos())
	Ent:SetPos(Pos)
	Ent:Spawn()
	
	local Phys = Ent:GetPhysicsObject()
	if !Phys:IsValid() then
		Ent:Remove()
		return
	end
 
	Aimvec:Mul(10000)
	Aimvec:Add(VectorRand(-10, 10))
	Phys:ApplyForceCenter( Aimvec )

	self.Weapon:TakePrimaryAmmo(1)
end