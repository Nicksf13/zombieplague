local PLAYER = FindMetaTable("Player")

function PLAYER:SetZombieClass(ZombieClass)
	self.ZombieClass = ZombieClass
	net.Start("SendZombieClass")
		net.WriteString(PlayerManager:GetPlayerID(self))
		net.WriteString(ZombieClass.Name)
	net.Broadcast()
end
function PLAYER:GetZombieClass()
	if !self.ZombieClass then
		self:SetZombieClass(ClassManager:GetZPClass("DefaultZombie", TEAM_ZOMBIES))
	end
	return self.ZombieClass
end
function PLAYER:SetNextZombieClass(NextZombieClass)
	self.NextZombieClass = NextZombieClass
end
function PLAYER:GetNextZombieClass()
	local NextZombieClass = self.NextZombieClass
	self.NextZombieClass = nil
	return NextZombieClass
end
function PLAYER:SetHumanClass(HumanClass)
	self.HumanClass = HumanClass
	net.Start("SendHumanClass")
		net.WriteString(PlayerManager:GetPlayerID(self))
		net.WriteString(HumanClass.Name)
	net.Broadcast()
end
function PLAYER:GetHumanClass()
	if !self.HumanClass then
		self:SetHumanClass(ClassManager:GetZPClass("DefaultHuman", TEAM_HUMANS))
	end
	return self.HumanClass
end
function PLAYER:SetNextHumanClass(NextHumanClass)
	self.NextHumanClass = NextHumanClass
end
function PLAYER:GetNextHumanClass()
	local NextHumanClass = self.NextHumanClass
	self.NextHumanClass = nil
	return NextHumanClass
end
function PLAYER:GetZPClass()
	if self:IsZombie() then
		return self:GetZombieClass()
	else
		return self:GetHumanClass()
	end
end

function PLAYER:SetAbilityPower(AbilityPower)
	self.AbilityPower = AbilityPower
	net.Start("SendAbilityPower")
		net.WriteString(PlayerManager:GetPlayerID(self))
		net.WriteInt(AbilityPower, 16)
	net.Broadcast()
end
function PLAYER:GetAbilityPower()
	return self.AbilityPower or -1
end
function PLAYER:DrainAbilityPower(Power)
	local AbilityPower = self.AbilityPower - Power
	if AbilityPower <= 0 then
		AbilityPower = 0

		hook.Call("PlayerAbilityPowerOver" .. self:SteamID64(), GAMEMODE)
	end
	
	self:SetAbilityPower(AbilityPower)
	self:AddRechargeOnAbilityPower(1)
end
function PLAYER:AddRechargeOnAbilityPower(Amount)
	local RechargeAbilityPower = "RechargeAbilityPower" .. self:SteamID64()
	hook.Add("SecondTickManager", RechargeAbilityPower, function()
		self:AddAbilityPower(Amount)
	end)

	local EventName = "ZPResetAbilityEvent" .. self:SteamID64()
	hook.Add(EventName, RechargeAbilityPower, function()
		hook.Remove("SecondTickManager", RechargeAbilityPower)
		hook.Remove(EventName, RechargeAbilityPower)
	end)
end
function PLAYER:AddAbilityPower(Power)
	local AbilityPower = self.AbilityPower + Power
	if AbilityPower >= self:GetMaxAbilityPower() then
		AbilityPower = self:GetMaxAbilityPower()

		hook.Remove("SecondTickManager", "RechargeAbilityPower" .. self:SteamID64())
	end

	self:SetAbilityPower(AbilityPower)
end

function PLAYER:SetMaxAbilityPower(MaxAbilityPower)
	self.MaxAbilityPower = MaxAbilityPower
	net.Start("SendMaxAbilityPower")
		net.WriteString(PlayerManager:GetPlayerID(self))
		net.WriteInt(MaxAbilityPower, 16)
	net.Broadcast()
end
function PLAYER:GetMaxAbilityPower()
	return self.MaxAbilityPower or -1
end

function PLAYER:SetAbilityTimer(TimerName, Seconds, TimerAction)
	local TimerNameWithSteamID64 = TimerName .. self:SteamID64()
	timer.Create(TimerNameWithSteamID64, Seconds, 1, TimerAction)

	local EventName = "ZPResetAbilityEvent" .. self:SteamID64()
	hook.Add(EventName, TimerNameWithSteamID64, function()
		timer.Destroy(TimerNameWithSteamID64)
		hook.Remove(EventName, TimerNameWithSteamID64)
	end)
end

function PLAYER:GiveZombieAllowedWeapon(Weap)
	self:AddZombieAllowedWeapon(Weap)
	self:Give(Weap)
end
function PLAYER:AddZombieAllowedWeapon(Weap)
	table.insert(self:GetZombieAllowedWeapons(), Weap)
end
function PLAYER:SetZombieAllowedWeapons(AllowedWeapons)
	self.AllowedWeapons = AllowedWeapons
end
function PLAYER:GetZombieAllowedWeapons()
	return self.AllowedWeapons or {}
end
function PLAYER:ZombieCanUseWeapon(Weap)
	if Weap == ZOMBIE_KNIFE then
		return true
	end
	for k, LocalWeap in pairs(self:GetZombieAllowedWeapons()) do
		if LocalWeap == Weap then
			return true
		end
	end
	return false
end
function PLAYER:RemoveZombieAllowedWeapon(Weapon)
	self:StripWeapon(Weapon)
	table.RemoveByValue(self:GetZombieAllowedWeapons(), Weapon)
end
function PLAYER:ResetZombieAllowedWeapons()
	self:SetZombieAllowedWeapons({ZOMBIE_KNIFE})
end
function PLAYER:SetFootstep(Footstep)
	self.Footstep = Footstep
	net.Start("SendFoostep")
		net.WriteString(PlayerManager:GetPlayerID(self))
		net.WriteBool(Footstep)
	net.Broadcast()
end
function PLAYER:GetFootstep()
	return self.Footstep
end
function PLAYER:ZombieMadness(ZombieMadnessTime)
	self:SetLight(Color(255, 0, 0))
	self:GodEnable()
	self:ZPEmitSound(SafeTableRandom(ZombieMadnessSounds), 5, true)
	self.OldWalkSpeed = self:GetWalkSpeed()
	self.selfOldRunSpeed = self:GetRunSpeed()
	self:SetWalkSpeed(200)
	self:SetRunSpeed(200)

	local ZombieMadnessIdentifier = "ZPZombieMadness" .. self:SteamID64()
	local ZombieMadnessDuration = ZombieMadnessTime and ZombieMadnessTime or 5
	if timer.Exists(ZombieMadnessIdentifier) then
		ZombieMadnessDuration = ZombieMadnessDuration + timer.TimeLeft(ZombieMadnessIdentifier)
		timer.Destroy(ZombieMadnessIdentifier)
	end

	timer.Create(ZombieMadnessIdentifier, ZombieMadnessDuration, 1, function()
		if IsValid(self) then
			self:SetLight(nil)
			self:GodDisable()
			self:SetWalkSpeed(self.OldWalkSpeed)
			self:SetRunSpeed(self.selfOldRunSpeed)
		end
	end)

	return ZombieMadnessIdentifier
end
---------------------------Damage---------------------------
function PLAYER:TakeLastDamage()
	self:SetLastDamage(CurTime())
end
function PLAYER:SetLastDamage(LastDamage)
	self.LastDamage = LastDamage
end
function PLAYER:GetLastDamage()
	return self.LastDamage or 0
end
function PLAYER:ShouldTakeFallDamage()
	local FallDamage = cvars.Number("zp_falldamage",  0)
	if FallDamage == FALL_DMG_NONE && !RoundManager:IsRealisticMod() then
		return false
	end
	if (self:IsZombie() && !self:GetZombieClass():FallFunction()) || (self:IsHuman() && !self:GetHumanClass():FallFunction()) then
		return false
	end
	
	return (FallDamage == FALL_DMG_ALL) || (self:IsZombie() && FALL_DMG_ZOMBIES) || (self:IsHuman() && FALL_DMG_HUMANS)
end
function PLAYER:AddTotalDamage(TotalDamage)
	TotalDamage = self:GetTotalDamage() + TotalDamage
	local AmmoPacks = math.floor(TotalDamage / cvars.Number("zp_ap_damage", 500))
	if AmmoPacks > 0 then
		self:GiveAmmoPacks(AmmoPacks)
	end
	self:SetTotalDamage(TotalDamage % cvars.Number("zp_ap_damage", 500))
end
function PLAYER:SetTotalDamage(TotalDamage)
	self.TotalDamage = TotalDamage
end
function PLAYER:GetTotalDamage()
	return self.TotalDamage or 0
end
function PLAYER:TakeArmorDamage(Dmg)
	if self:Armor() > 0 then
		local Armor = self:Armor() - Dmg
		if Armor < 0 then
			Armor = 0
			if cvars.Bool("zp_realistic_mode", false) then
				self:SetArmor(Armor)
				return (Armor * -1)
			end
		end
		self:SetArmor(Armor)
		return 0
	end
	return Dmg
end
---------------------------Damage---------------------------
function PLAYER:SetTalking(Talking)
	self.Talking = Talking
end
function PLAYER:IsTalking()
	return self.Talking or false
end
-------------------------Ammo Packs-------------------------
function PLAYER:GiveAmmoPacks(Amount)
	self:SetAmmoPacks(self:GetAmmoPacks() + Amount)
end
function PLAYER:TakeAmmoPacks(Amount)
	self:SetAmmoPacks(self:GetAmmoPacks() - Amount)
end
function PLAYER:SetAmmoPacks(AmmoPacks, NotSave)
	self.AmmoPacks = AmmoPacks
	net.Start("SendAmmoPacks")
		net.WriteString(PlayerManager:GetPlayerID(self))
		net.WriteInt(AmmoPacks, 32)
	net.Broadcast()

	if !NotSave && Bank.ShouldSaveAmmoPacks then
		Bank:SetPlayerAmmoPacks(self, AmmoPacks)
	end	
end
function PLAYER:GetAmmoPacks()
	return self.AmmoPacks or 0
end
-------------------------Ammo Packs-------------------------
---------------------------Battery--------------------------
function PLAYER:ChargeBattery(Amount)
	Amount = self:GetBattery() + Amount
	if Amount > self:GetMaxBatteryCharge() then
		Amount = self:GetMaxBatteryCharge()
	end
	self:SetBattery(Amount)
	
	if Amount == self:GetMaxBatteryCharge() then
		hook.Call("PlayerBatteryCharge", GAMEMODE, self)
	end
end
function PLAYER:DrainBattery(Amount)
	Amount = self:GetBattery() - Amount
	if Amount < 0 then
		Amount = 0
	end
	self:SetBattery(Amount)
	
	if Amount == 0 then
		hook.Call("PlayerBatteryOver", GAMEMODE, self)
	end
end
function PLAYER:SetBattery(Battery)
	self.Battery = Battery
	net.Start("SendBatteryCharge")
		net.WriteString(PlayerManager:GetPlayerID(self))
		net.WriteFloat(Battery)
	net.Broadcast()
end
function PLAYER:GetBattery()
	return self.Battery or self:GetMaxBatteryCharge()
end
function PLAYER:SetMaxBatteryCharge(MaxCharge)
	self.MaxCharge = MaxCharge
	net.Start("SendMaxBatteryCharge")
		net.WriteString(PlayerManager:GetPlayerID(self))
		net.WriteFloat(MaxCharge)
	net.Broadcast()
end
function PLAYER:GetMaxBatteryCharge()
	return self.MaxCharge or 100
end
---------------------------Battery--------------------------
---------------------------Breath---------------------------
function PLAYER:AddBreath(Breath)
	self:SetBreath(self:GetBreath() + Breath)
end
function PLAYER:TakeBreath(Breath)
	self:SetBreath(self:GetBreath() - Breath)
end
function PLAYER:SetBreath(Breath)
	if Breath <= 0 then
		Breath = 0
		local DmgInfo = DamageInfo()
		DmgInfo:SetDamage(cvars.Number("zp_breath_damage", 5))
		DmgInfo:SetDamageType(DMG_DROWNRECOVER)
		self:TakeDamageInfo(DmgInfo)
	elseif Breath > self:GetMaxBreath() then
		Breath = self:GetMaxBreath()
	end
	self.Breath = Breath
	
	net.Start("SendBreath")
		net.WriteString(PlayerManager:GetPlayerID(self))
		net.WriteFloat(Breath)
	net.Broadcast()
end
function PLAYER:GetBreath()
	return self.Breath or 100
end
function PLAYER:SetMaxBreath(MaxBreath)
	self.MaxBreath = MaxBreath

	net.Start("SendMaxBreath")
		net.WriteString(PlayerManager:GetPlayerID(self))
		net.WriteFloat(MaxBreath)
	net.Broadcast()
end
function PLAYER:GetMaxBreath()
	return self.MaxBreath or 100
end
---------------------------Breath---------------------------
-------------------------Nightvision------------------------
function PLAYER:SetNightvision(Nightvision)
	self.Nightvision = Nightvision
	
	if self:Alive() && self:IsHuman() then
		if RoundManager:IsRealisticMod() then
			if Nightvision then
				self:EmitSound(NIGHTVISION_ON_SOUND, 75, 100, 0.25)
			elseif !self:NightvisionIsOn() then
				self:EmitSound(NIGHTVISION_OFF_SOUND, 75, 100, 0.25)
			end
		else
			if Nightvision then
				SendSound(self, NIGHTVISION_ON_SOUND)
			elseif !self:NightvisionIsOn() then
				SendSound(self, NIGHTVISION_OFF_SOUND)
			end
		end
	end
	net.Start("SendNightvision")
		net.WriteBool(Nightvision)
	net.Send(self)
end
function PLAYER:NightvisionIsOn()
	return self.Nightvision
end
-------------------------Nightvision------------------------
---------------------------Weapons--------------------------
function PLAYER:GiveWeapon(Weap)
	Weap:GiveWeapon(self)
end
function PLAYER:SetPrimaryWeapon(PrimaryWeapon)
	self.PrimaryWeapon = PrimaryWeapon
	if PrimaryWeapon then
		if !self:GetPrimaryWeaponGiven() then
			self:GiveWeapon(PrimaryWeapon)
			self:SetPrimaryWeaponGiven(true)
		end
	end
end
function PLAYER:GetPrimaryWeapon()
	return self.PrimaryWeapon
end
function PLAYER:SetSecondaryWeapon(SecondaryWeapon)
	self.SecondaryWeapon = SecondaryWeapon
	if SecondaryWeapon then
		if !self:GetSecondaryWeaponGiven() then
			self:GiveWeapon(SecondaryWeapon)
			self:SetSecondaryWeaponGiven(true)
		end
	end
end
function PLAYER:GetSecondaryWeapon()
	return self.SecondaryWeapon
end
function PLAYER:SetPrimaryWeaponGiven(PrimaryWeaponGiven)
	self.PrimaryWeaponGiven = PrimaryWeaponGiven
end
function PLAYER:GetPrimaryWeaponGiven()
	return self.PrimaryWeaponGiven or false
end
function PLAYER:SetSecondaryWeaponGiven(SecondaryWeaponGiven)
	self.SecondaryWeaponGiven = SecondaryWeaponGiven
end
function PLAYER:GetSecondaryWeaponGiven()
	return self.SecondaryWeaponGiven or false
end
function PLAYER:SetMeleeWeapon(MeleeWeapon)
	self.MeleeWeapon = MeleeWeapon
	if MeleeWeapon then
		if !self:GetMeleeWeaponGiven() then
			self:GiveWeapon(MeleeWeapon)
			self:SetMeleeWeaponGiven(true)
		end
	end
end
function PLAYER:GetMeleeWeapon()
	return self.MeleeWeapon
end
function PLAYER:SetMeleeWeaponGiven(MeleeWeaponGiven)
	self.MeleeWeaponGiven = MeleeWeaponGiven
end
function PLAYER:GetMeleeWeaponGiven()
	return self.MeleeWeaponGiven or false
end
---------------------------Weapons--------------------------
--------------------------Languages-------------------------
function PLAYER:SetLanguage(Language, ShouldSave)
	self.Language = Language
	net.Start("SendPlayerLanguage")
		net.WriteString(Language)
		net.WriteTable(Dictionary:GetClientSideLanguageBook(Language))
		net.WriteBool(ShouldSave)
	net.Send(self)
end
function PLAYER:GetLanguage()
	return self.Language or "en-us"
end
--------------------------Languages-------------------------
---------------------------Move-----------------------------
function PLAYER:SetLastMove(LastMove)
	self.LastMove = LastMove
end
function PLAYER:GetLastMove()
	return self.LastMove or CurTime() + 1
end
function PLAYER:MoveSpectateID(Move, Players)
	self.SpectateID = ((self:GetSpectateID() + Move + #Players) % #Players)
	self:SpectateEntity(Players[self:GetSpectateID() + 1])
	self:SetupHands(Players[self:GetSpectateID() + 1])
end
function PLAYER:GetSpectateID()
	return self.SpectateID or 1
end
function PLAYER:SetAuxGravity(AuxGravity)
	self.AuxGravity = AuxGravity
end
function PLAYER:GetAuxGravity()
	return self.AuxGravity or 1
end
---------------------------Move-----------------------------
-------------------------Infection--------------------------
function PLAYER:Infect(SilentInfection)
	local ZombieClass = self:GetNextZombieClass()
	if ZombieClass then
		self:SetZombieClass(ZombieClass)
	end

	local HoldingWeapon = self:GetActiveWeapon()
	if IsValid(HoldingWeapon) then
		self:DropWeapon(HoldingWeapon)
	end
	
	self:SetTeam(TEAM_ZOMBIES)
	self:StripWeapons()
	
	local ZombieClass = self:IsBot() and SafeTableRandom(ClassManager:GetZombieClasses()) or self:GetZombieClass()
	if ZombieClass.Scale then
		self:SetModelScale(ZombieClass.Scale, 0)
	end
	self:SetMaxHealth(ZombieClass.MaxHealth)
	self:SetHealth(ZombieClass.MaxHealth)
	self:SetWalkSpeed(ZombieClass.Speed)
	self:SetRunSpeed(cvars.Bool("zp_zombie_should_run", true) and ZombieClass.RunSpeed or ZombieClass.Speed)
	self:SetCrouchedWalkSpeed(ZombieClass.CrouchSpeed)
	self:SetAuxGravity(ZombieClass.Gravity)
	self:SetMaxBreath(ZombieClass.Breath)
	self:SetBreath(ZombieClass.Breath)
	self:SetJumpPower(ZombieClass.JumpPower)
	self:SetDamageAmplifier(ZombieClass.DamageAmplifier)
	self:SetFootstep((RoundManager:IsRealisticMod() || cvars.Bool("zp_zombie_footstep", false)) && ZombieClass.Footstep)
	if self:FlashlightIsOn() then
		self:Flashlight(false)
	end
	self:AllowFlashlight(false)
	
	self:SetModel(ZombieClass.PModel)
	self:SetupHands()
	
	ZombieClass:WeaponGive(self)

	if(!SilentInfection) then
		self:EmitSound(SafeTableRandom(InfectionSounds))
	end

	local Ability = ZombieClass.Ability
	if Ability then
		self:SetMaxAbilityPower(Ability.MaxAbilityPower)
		self:SetAbilityPower(Ability.MaxAbilityPower)

		SendPopupMessage(self, Dictionary:GetPhrase("NoticeHasHability", self))
	else
		self:SetMaxAbilityPower(-1)
		self:SetAbilityPower(-1)
	end

	self:ScreenFade(SCREENFADE.IN, Color(0, 255, 0, 128), 0.3, 0)
	if cvars.Bool("zp_zombie_screen_filter", true) then
		self:SetScreenFilter(Color(255, 0, 0, 2))
	end
end
function PLAYER:MakeHuman()
	local HumanClass = self:GetNextHumanClass()
	if HumanClass then
		self:SetHumanClass(HumanClass)
	end
	
	self:SetTeam(TEAM_HUMANS)
	self:StripWeapons()
	
	local HumanClass = self:IsBot() and SafeTableRandom(ClassManager:GetHumanClasses()) or self:GetHumanClass()
	self:SetMaxHealth(HumanClass.MaxHealth)
	if HumanClass.Armor then
		self:SetArmor(HumanClass.Armor)
	end
	if HumanClass.Scale then
		self:SetModelScale(HumanClass.Scale, 0)
	end
	self:SetHealth(HumanClass.MaxHealth)
	self:SetWalkSpeed(HumanClass.Speed)
	self:SetRunSpeed(HumanClass.RunSpeed)
	self:SetCrouchedWalkSpeed(HumanClass.CrouchSpeed)
	self:SetAuxGravity(HumanClass.Gravity)
	self:SetJumpPower(HumanClass.JumpPower)
	self:SetModel(HumanClass.PModel)
	self:SetMaxBreath(HumanClass.Breath)
	self:SetBreath(HumanClass.Breath)
	self:SetMaxBatteryCharge(HumanClass.Battery)
	self:SetDamageAmplifier(HumanClass.DamageAmplifier)
	self:SetFootstep(HumanClass.Footstep)
	self:AllowFlashlight(true)
	self:SetupHands()
	self:SetPrimaryWeaponGiven(false)
	self:SetSecondaryWeaponGiven(false)
	self:SetMeleeWeaponGiven(false)
	
	if !self:IsBot() then
		local HasOpenChooseMenu = false
		if self:GetPrimaryWeapon() then
			self:GiveWeapon(self:GetPrimaryWeapon())
			self:SetPrimaryWeaponGiven(true)
		else
			WeaponManager:OpenWeaponMenu(self, WEAPON_PRIMARY)

			HasOpenChooseMenu = true
		end
		
		if self:GetSecondaryWeapon() then
			self:GiveWeapon(self:GetSecondaryWeapon())
			self:SetSecondaryWeaponGiven(true)
		elseif !HasOpenChooseMenu then
			WeaponManager:OpenWeaponMenu(self, WEAPON_SECONDARY)

			HasOpenChooseMenu = true
		end

		if self:GetMeleeWeapon() then
			self:GiveWeapon(self:GetMeleeWeapon())
			self:SetMeleeWeaponGiven(true)
		elseif !HasOpenChooseMenu then
			WeaponManager:OpenWeaponMenu(self, WEAPON_MELEE)
		end
	else
		self:GiveWeapon(SafeTableRandom(WeaponManager:GetWeaponsTableByWeaponType(WEAPON_PRIMARY)))
	end
	
	local Ability = HumanClass.Ability
	if Ability then
		self:SetMaxAbilityPower(Ability.MaxAbilityPower)
		self:SetAbilityPower(Ability.MaxAbilityPower)

		SendPopupMessage(self, Dictionary:GetPhrase("NoticeHasHability", self))
	else
		self:SetMaxAbilityPower(-1)
		self:SetAbilityPower(-1)
	end
	
	if cvars.Bool("zp_zombie_screen_filter", true) then
		self:SetScreenFilter(nil)
	end
end
function PLAYER:SetDamageAmplifier(DamageAmplifier)
	self.DamageAmplifier = DamageAmplifier
end
function PLAYER:GetDamageAmplifier()
	return self.DamageAmplifier or 1
end
function PLAYER:Cure()
	self:MakeHuman()
	self:EmitSound(SafeTableRandom(CureSounds))
end
function PLAYER:MakeNemesis()
	self:Infect()
	local HealthMode = cvars.Number("zp_nemesis_health_mode", 0)
	
	if HealthMode == 1 then
		local Health = self:Health() + RoundManager:CountHumansAlive() * cvars.Number("zp_nemesis_health_player", 500)
		self:SetHealth(Health)
		self:SetMaxHealth(Health)
	elseif HealthMode == 2 then
		self:SetHealth(cvars.Number("zp_nemesis_health", 3000))
		self:SetMaxHealth(cvars.Number("zp_nemesis_health", 3000))
	else
		self:SetHealth(NemesisClass.Health)
		self:SetMaxHealth(NemesisClass.Health)
	end
	if !cvars.Bool("zp_nemesis_earn", false) then
		self:SetWalkSpeed(NemesisClass.Speed)
		self:SetRunSpeed(NemesisClass.RunSpeed)
		self:SetCrouchedWalkSpeed(NemesisClass.CrouchedSpeed)
		self:SetAuxGravity(NemesisClass.Gravity)
	end
	if !cvars.Bool("zp_nemesis_override_player_mode", false) then
		self:SetModel(NemesisClass.PlayerModel)
	end
	self:SetFootstep(true)
	self:SetDamageAmplifier(cvars.Number("zp_nemesis_damage", 10))
	self:SetLight(NEMESIS_COLOR)
	self:SetNemesis(true)
end
function PLAYER:SetNemesis(Nemesis)
	self.Nemesis = Nemesis
	net.Start("SendNemesis")
		net.WriteString(PlayerManager:GetPlayerID(self))
		net.WriteBool(Nemesis)
	net.Broadcast()
end
function PLAYER:IsNemesis()
	return self.Nemesis
end
function PLAYER:MakeSurvivor()
	local HealthMode = cvars.Number("zp_survivor_health_mode", 1)
	
	if HealthMode == 1 then
		self:SetHealth(self:Health() + RoundManager:CountZombiesAlive() * cvars.Number("zp_survivor_health_player", 30))
	elseif HealthMode == 2 then
		self:SetHealth(cvars.Number("zp_survivor_health", 3000))
	else
		self:SetHealth(SurvivorClass.Health)
	end
	if !cvars.Bool("zp_survivor_earn", false) then
		self:SetWalkSpeed(SurvivorClass.Speed)
		self:SetRunSpeed(SurvivorClass.RunSpeed)
		self:SetCrouchedWalkSpeed(SurvivorClass.CrouchedSpeed)
		self:SetAuxGravity(SurvivorClass.Gravity)
	end
	if !cvars.Bool("zp_survivor_override_player_mode", false) then
		self:SetModel(SurvivorClass.PlayerModel)
	end
	self:SetFootstep(false)
	self:SetDamageAmplifier(cvars.Number("zp_survivor_damage", 2.0))
	self:SetLight(SURVIVOR_COLOR)
	self:SetSurvivor(true)
end
function PLAYER:SetSurvivor(Survivor)
	self.Survivor = Survivor
	net.Start("SendSurvivor")
		net.WriteString(PlayerManager:GetPlayerID(self))
		net.WriteBool(Survivor)
	net.Broadcast()
end
function PLAYER:IsSurvivor()
	return self.Survivor
end
function PLAYER:IsHuman()
	return self:Team() == TEAM_HUMANS
end
function PLAYER:IsZombie()
	return self:Team() == TEAM_ZOMBIES
end
-------------------------Infection--------------------------
-------------------------EmitSound--------------------------
function PLAYER:ZPEmitSound(SoundPath, DelayTime, Force)
	if SoundPath then
		if self:ZPCanEmitSound() || Force then
			self.ZPEmit = CurTime() + DelayTime
			self:EmitSound(SoundPath)
		end
	end
end
function PLAYER:ZPCanEmitSound()
	return CurTime() > (self.ZPEmit or 0)
end
-------------------------EmitSound--------------------------
-----------------------Special Lights-----------------------
function PLAYER:SetLight(Light)
	net.Start("SendLight")
		net.WriteString(PlayerManager:GetPlayerID(self))
		net.WriteBool(!!Light)
		if Light then
			net.WriteColor(Light)
		end
	net.Broadcast()
	self.Light = Light
end
function PLAYER:GetLight()
	return self.Light
end
-----------------------Special Lights-----------------------
-----------------------Screen Filter------------------------
function PLAYER:SetScreenFilter(ScreenFilter)
	net.Start("SendScreenFilter")
		net.WriteString(PlayerManager:GetPlayerID(self))
		net.WriteBool(!!ScreenFilter)
		if ScreenFilter then
			net.WriteColor(ScreenFilter)
		end
	net.Broadcast()

	self.ScreenFilter = ScreenFilter
end
---------------------frags for damage-----------------------
hook.Add("EntityTakeDamage", "zzzzzzzzzzzFragsForDamage", function(ply, dmg)
	if ply:IsPlayer() and ply:IsZombie() then
		local att = dmg:GetAttacker()
		if IsValid(att) and att:IsPlayer() and att:IsHuman() then
			att["FFD"] = (att["FFD"] or 0) + dmg:GetDamage()
			if (att["FFD"] > 750) then
				att["FFD"] = 0
				att:AddFrags(1)
			end
		end
	end
end)
---------------------------Filter---------------------------
net.Receive("SendVoice", function(len, ply)
	ply:SetTalking(net.ReadBool())
end)

util.AddNetworkString("SendPlayerLanguage")
util.AddNetworkString("SendAmmoPacks")
util.AddNetworkString("SendBatteryCharge")
util.AddNetworkString("SendMaxBatteryCharge")
util.AddNetworkString("SendZombieClass")
util.AddNetworkString("SendHumanClass")
util.AddNetworkString("SendNemesis")
util.AddNetworkString("SendSurvivor")
util.AddNetworkString("SendNightvision")
util.AddNetworkString("SendVoice")
util.AddNetworkString("SendLight")
util.AddNetworkString("SendFoostep")
util.AddNetworkString("SendAbilityPower")
util.AddNetworkString("SendMaxAbilityPower")
util.AddNetworkString("SendBreath")
util.AddNetworkString("SendMaxBreath")
util.AddNetworkString("SendScreenFilter")