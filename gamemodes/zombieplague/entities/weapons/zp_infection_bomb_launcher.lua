SWEP.PrintName			= "Infection Grenade"
SWEP.Author			= "The Fire Fuchs"
SWEP.Instructions		= "Infects an enemy"
SWEP.Base = "weapon_base"
SWEP.Spawnable = true
SWEP.AdminOnly = true
SWEP.UseHands = true
SWEP.DrawAmmo			= true
SWEP.DrawCrosshair		= true

SWEP.Primary.ClipSize		= 1
SWEP.Primary.DefaultClip	= 1
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo		= "Snark"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo		= "none"

SWEP.Weight			= 5
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false

SWEP.Slot			= 5
SWEP.SlotPos			= 5

SWEP.ViewModel			= "models/weapons/c_bugbait.mdl"
SWEP.WorldModel			= "models/weapons/w_bugbait.mdl"

SWEP.AlternateSounds = {
	"weapons/bugbait/bugbait_squeeze1.wav",
	"weapons/bugbait/bugbait_squeeze2.wav",
	"weapons/bugbait/bugbait_squeeze3.wav"
}

function SWEP:Initialize()
	self:SetHoldType("grenade")

	self.ProjectileMode = EXPLODE_ON_HIT_MODE
	self.ProjectileDelay = 5
	timer.Create("SetIdle" .. CurTime(), 0.1, 1, function()
		self.Weapon:SendWeaponAnim(ACT_VM_IDLE)
	end)
end
function SWEP:PrimaryAttack()
	if not self:CanPrimaryAttack() then return end

	self.Weapon:SendWeaponAnim(ACT_VM_THROW)
	self.Owner:SetAnimation(PLAYER_ATTACK1)
	self:ShootGrenade()

	if self:Clip1() == 0 then
		self:Reload()
	end
end

function SWEP:SecondaryAttack()
	if !self:GetNW2Bool("IsReloading") then
		self.ProjectileMode = (self.ProjectileMode + 1) % 3

		self.Weapon:SendWeaponAnim(ACT_VM_SECONDARYATTACK)

		if CLIENT then
			local RandomSound, k = table.Random(self.AlternateSounds)
			self:EmitSound(RandomSound)

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
end

function SWEP:Reload()
    if (self:Clip1() == self.Primary.ClipSize or self:GetOwner():GetAmmoCount(self.Primary.Ammo) <= 0) then return end
	self:SetNW2Bool("IsReloading", true)
   	self:DefaultReload(ACT_VM_RELOAD)
	local SequenceDuration = 2
    self:SetNextPrimaryFire(CurTime() + SequenceDuration)
	timer.Create("SequenceResetInfectionGrenade" .. CurTime(), SequenceDuration, 1, function()
		if IsValid(self.Weapon) then
			self.Weapon:SendWeaponAnim(ACT_VM_IDLE)
			self:SetNW2Bool("IsReloading", false)
		end
	end)
end

-- Thanks https://wiki.facepunch.com/gmod/Chair_Throwing_Gun
function SWEP:ShootGrenade()
	local Owner = self:GetOwner()

	if !Owner:IsValid() then return end

	if CLIENT then return end

	local Ent = ents.Create("zp_infection_grenade")
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
 
	Aimvec:Mul(1000)
	Aimvec:Add(VectorRand(-10, 10))
	Phys:ApplyForceCenter( Aimvec )

	self.Weapon:TakePrimaryAmmo(1)
end