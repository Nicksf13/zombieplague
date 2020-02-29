ConvarManager:CreateConVar("zp_falldamage", 1, 8, "cvar used to set fall damage for players (1 - None, 2 - Only zombies, 3 - Only Humans, 4 - Everyone)")
ConvarManager:CreateConVar("zp_nemesis_damage", 10, 8, "cvar used to set how stronger nemesis will be.")
ConvarManager:CreateConVar("zp_survivor_damage", 1.1, 8, "cvar used to set how stronger survivor will be.")
ConvarManager:CreateConVar("zp_battery_flashlight_should_drain", 0, "cvar used to set if flashlight should drain battery")
ConvarManager:CreateConVar("zp_battery_flashlight_drain", 1, 8, "cvar used to set flashlight battery drain")
ConvarManager:CreateConVar("zp_battery_nightvision_should_drain", 0, "cvar used to set if nightvision should drain battery")
ConvarManager:CreateConVar("zp_battery_nightvision_drain", 1, 8, "cvar used to set nightvision battery drain")
ConvarManager:CreateConVar("zp_battery_voice_should_drain", 0, "cvar used to set if voice should drain battery")
ConvarManager:CreateConVar("zp_battery_voice_drain", 0.5, 8, "cvar used to set voice battery drain")
ConvarManager:CreateConVar("zp_battery_charge", 0.5, 8, "cvar used to set battery recharge")
ConvarManager:CreateConVar("zp_water_drain", 0, 8, "cvar used to set if water will drain player's breath.")
ConvarManager:CreateConVar("zp_run_drain", 0, 8, "cvar used to set if run will drain player's breath.")
ConvarManager:CreateConVar("zp_breath_drain", 1, 8, "cvar used to set breath drain")
ConvarManager:CreateConVar("zp_breath_damage", 1, 8, "cvar used to set breath damage")
ConvarManager:CreateConVar("zp_breath_recover", 0.5, 8, "cvar used to set breath recover")
ConvarManager:CreateConVar("zp_last_human_reward_mode", 1, 8, "cvar used to set last human reward")
ConvarManager:CreateConVar("zp_last_human_reward_health", 25, 8, "cvar used to set last human health reward")
ConvarManager:CreateConVar("zp_last_zombie_reward_mode", 1, 8, "cvar used to set last zombie reward")
ConvarManager:CreateConVar("zp_last_zombie_reward_health", 250, 8, "cvar used to set last zombie health reward")
ConvarManager:CreateConVar("zp_health_should_regen", 1, 8, "cvar used to set if zombies will regen health.")
ConvarManager:CreateConVar("zp_health_regen_time_delay", 20, 8, "cvar used to set the delay time after last damage to regen zombie's health.")
ConvarManager:CreateConVar("zp_health_regen", 10, 8, "cvar used to set how much health zombies will regen.")
ConvarManager:CreateConVar("zp_clip_mode", 0, 8, "cvar used to set the clip mode of the weapons.")
ConvarManager:CreateConVar("zp_zombie_should_run", 1, 8, "cvar used to enable zombies to run")
ConvarManager:CreateConVar("zp_spectate_team_ony", 1, 8, "cvar used to define if the spectator can only see his teammates")

FALL_DMG_NONE = 0
FALL_DMG_ZOMBIES = 1
FALL_DMG_HUMANS = 2
FALL_DMG_ALL = 3

WMODE_NONE = 0
WMODE_INFINITE_CLIP = 1
WMODE_INFINITE = 2

local MoveKeys = {IN_ATTACK,
	IN_ATTACK2,
	IN_BACK,
	IN_DUCK,
	IN_FORWARD,
	IN_JUMP,
	IN_MOVELEFT,
	IN_MOVERIGHT,
	IN_RELOAD,
	IN_SPEED,
	IN_USE,
	IN_WALK,
	IN_ZOOM,
	IN_WEAPON1,
	IN_WEAPON2}

function GM:EntityTakeDamage(target, dmginfo)
	local Attacker = dmginfo:GetAttacker()
	if Attacker:IsPlayer() then
		local Multiplier = WeaponManager:GetWeaponMultiplier(dmginfo:GetInflictor():GetClass())
		if !Multiplier && Attacker:Alive() && IsValid(Attacker:GetActiveWeapon()) then
			Multiplier = WeaponManager:GetWeaponMultiplier(Attacker:GetActiveWeapon():GetClass())
		end
		dmginfo:ScaleDamage(Multiplier and Multiplier or 1)
		dmginfo:ScaleDamage(Attacker:GetDamageAmplifier())
	end

	if target:IsPlayer() then
		if !RoundManager:IsRealisticMod() && RoundManager:GetRoundState() != ROUND_PLAYING then
			return true
		end
		if Attacker:IsPlayer() then
			if target:Team() != Attacker:Team() then
				if Attacker:IsZombie() then
					local Damage = target:TakeArmorDamage(dmginfo:GetDamage())
					if Damage > 0 then
						if RoundManager:GetRoundState() == ROUND_PLAYING && !RoundManager:IsSpecialRound() && !RoundManager:LastHuman() then
							InfectionManager:Infect(target, Attacker)
						else
							dmginfo:SetDamage(Damage)
						end
					else
						return true
					end
				else
					Attacker:AddTotalDamage(dmginfo:GetDamage())
					if target:IsNemesis() then
						target:ZPEmitSound(SafeTableRandom(NemesisDamageSounds), 1)
					else
						target:ZPEmitSound(SafeTableRandom(GenericDamageSounds), 1)
					end
					hook.Call("ZPHumanDamage", GAMEMODE, target, Attacker, dmginfo)
				end
			end
		elseif target:IsZombie() then
			if dmginfo:IsDamageType(DMG_FALL) then
				if dmginfo:GetDamage() > 0 then
					target:ZPEmitSound(SafeTableRandom(FallDamageSounds), 1)
				end
			elseif dmginfo:IsDamageType(DMG_BURN) then
				target:ZPEmitSound(SafeTableRandom(BurnDamageSounds), 1)
			else
				target:ZPEmitSound(SafeTableRandom(GenericDamageSounds), 1)
			end
		end
		target:TakeLastDamage()
	else
		dmginfo:ScaleDamage(cvars.Number("zp_map_prop_damage_multiplier", 1))
	end
end
function GM:GetFallDamage(ply, speed)
	return (ply:ShouldTakeFallDamage() and math.max(0, math.ceil(0.2418*speed - 141.75)) or 0) -- https://wiki.garrysmod.com/page/GM/GetFallDamage
end
function GM:PlayerShouldTakeDamage(ply, Attacker)
	if cvars.Bool("zp_realistic_mode", false) then
		return true
	end
	if RoundManager:GetRoundState() != ROUND_PLAYING then
		return false
	end
	if Attacker:IsPlayer() then
		return Attacker:Team() != ply:Team()
	end
	return true
end
function GM:AllowPlayerPickup(ply, item)
	return false
end
function GM:ShowSpare1(ply)
end
function GM:ShowSpare2(ply)
end
function GM:PlayerDeathSound()
	return true
end
function GM:PlayerCanHearPlayersVoice(Listener, Talker)
	if RoundManager:GetRoundState() != ROUND_PLAYING then
		return true
	end
	if RoundManager:IsRealisticMod() then
		return Listener:Team() == Talker:Team() && Listener:Alive() == Talker:Alive()
	end
	if !Listener:Alive() then
		return true
	end
	if !cvars.Bool("zp_voice_all", true) then
		if !cvars.Bool("zp_can_hear_death", true) then
			return Listener:Alive() == Talker:Alive() && Listener:Team() == Talker:Team()
		end
		return Listener:Team() == Talker:Team()
	end
	if !cvars.Bool("zp_can_hear_death", true) then
		return Listener:Alive() == Talker:Alive()
	end
	return true
end
function GM:PlayerCanSeePlayersChat(txt, teamtalk, Listener, Talker)
	if RoundManager:GetRoundState() != ROUND_PLAYING then
		return true
	end
	if RoundManager:IsRealisticMod() then
		return Listener:Team() == Talker:Team() && Listener:Alive() == Talker:Alive()
	end
	if !Listener:Alive() then
		if teamtalk then
			return Listener:Team() == Talker:Team()
		end
		return true
	end
	if teamtalk || !cvars.Bool("zp_chat_all", true)  then
		if !cvars.Bool("zp_can_see_death", true) then
			return Listener:Team() == Talker:Team() && Listener:Alive() == Talker:Alive()
		end
		return Listener:Team() == Talker:Team() 
	end
	if !cvars.Bool("zp_can_see_death", true) then
		return Listener:Alive() == Talker:Alive()
	end
	return true
end
function GM:PlayerSpawn(ply)
	if ply.FirstSpawn then
		if ply:Team() != TEAM_SPECTATOR then
			ply:UnSpectate()

			hook.Call("PlayerSetModel", GAMEMODE, ply)
			hook.Call("PlayerLoadout", GAMEMODE, ply)
		end
	else
		ply:KillSilent()
		ply:Spectate(6)
		ply.FirstSpawn = true
	end
end
function GM:PlayerDeathThink(ply)
	if PlayerCanSpawn(ply) then
		ply:Spawn()
		return true
	end
	if CurTime() - ply.DeathTime > 3 then
		CalculateSpectator(ply)
	end
	return false
end
function CalculateSpectator(ply)
	local PlayersToObserve
	local SpectateTeamOnly = cvars.Bool("zp_spectate_team_ony", true)
	if RoundManager:IsRealisticMod() || SpectateTeamOnly then
		if ply:IsZombie() then
			PlayersToObserve = RoundManager:GetAliveZombies()
		else
			PlayersToObserve = RoundManager:GetAliveHumans()
		end
	else
		PlayersToObserve = RoundManager:GetPlayersToPlay(true)
	end
	if #PlayersToObserve > 0 then
		local Observed = ply:GetObserverTarget()
		if (!Observed || !ply:GetObserverTarget():IsPlayer() || !ply:GetObserverTarget():Alive() || (SpectateTeamOnly && Observed:Team() != ply:Team())) && ply:GetObserverMode() != OBS_MODE_ROAMING then
			ply:MoveSpectateID(0, PlayersToObserve)
		elseif ply:KeyPressed(IN_JUMP) then
			ply:Spectate(((ply:GetObserverMode() + 1) % 3) + 4)
		elseif ply:KeyPressed(IN_ATTACK) then
			ply:MoveSpectateID(1, PlayersToObserve)
		elseif ply:KeyPressed(IN_ATTACK2) then
			ply:MoveSpectateID(-1, PlayersToObserve)
		end
	elseif ply:GetObserverMode() != OBS_MODE_ROAMING then
		ply:Spectate(OBS_MODE_ROAMING)
	end
	PlayersToObserve = nil
end
function ToggleNightvision(ply)
	if ply:GetBattery() > 0 then
		ply:SetNightvision(!ply:NightvisionIsOn())
	end
end
--hook.Add("HalfSecondTickManager", "ZPReloadManager", function()
--	if cvars.Number("zp_clip_mode", 0) == WMODE_INFINITE_CLIP then
--		for k, ply in pairs(player.GetAll()) do
--			if ply:Alive() then
--				if WeaponManager:IsChosenWeapon(ply:GetActiveWeapon():GetClass()) then
--					local Weapon = ply:GetActiveWeapon()
--					if Weapon:GetPrimaryAmmoType() != -1 && ply:GetAmmoCount(Weapon:GetPrimaryAmmoType()) != (Weapon:GetMaxClip1() * 2) then
--						ply:SetAmmo(Weapon:GetMaxClip1() * 2, Weapon:GetPrimaryAmmoType())
--					end
--				end
--			end
--		end
--	end
--end)
hook.Add("EntityFireBullets", "ZPReloadManager", function(Attacker)
	if cvars.Number("zp_clip_mode", 0) == WMODE_INFINITE && WeaponManager:IsChosenWeapon(Attacker:GetActiveWeapon():GetClass()) then
		local Weapon = Attacker:GetActiveWeapon()
		Weapon:SetClip1(Weapon:GetMaxClip1())
		Weapon:SetClip2(Weapon:GetMaxClip2())
	end
end)
hook.Add("PlayerDeath", "ZPPlayerDeath", function(ply, wep, killer)
	ply.DeathTime = CurTime()
	ply:SetPrimaryWeaponGiven(false)
	ply:SetSecondaryWeaponGiven(false)
	ply:SetLight(nil)
	if ply:IsZombie() then
		ply:EmitSound(SafeTableRandom(ZombieDeathSounds))
		if RoundManager:LastZombie() then
			hook.Call("ZPLastZombieEvent")
		end
		if killer:IsPlayer() then
			killer:GiveAmmoPacks(cvars.Number("zp_ap_kill_zombie", 5))

			ply:Spectate(OBS_MODE_CHASE)
			ply:SpectateEntity(killer)
		end
	else
		if RoundManager:LastHuman() then
			hook.Call("ZPLastHumanEvent")
		end
		if killer:IsPlayer() then
			killer:GiveAmmoPacks(cvars.Number("zp_ap_kill_zombie", 5))

			ply:Spectate(OBS_MODE_CHASE)
			ply:SpectateEntity(killer)
		end
	end

	hook.Call("ZPResetAbilityEvent" .. ply:SteamID64(), GAMEMODE)
end)
function PlayerCanSpawn(ply)
	if table.HasValue(RoundManager:GetPlayersToPlay(), ply) then
		if RoundManager:GetRoundState() == ROUND_PLAYING then
			if RoundManager:IsDeathMatch() then
				return true
			end
		end
		return RoundManager:GetRoundState() == ROUND_STARTING_NEW_ROUND || RoundManager:GetRoundState() == ROUND_WAITING_PLAYERS
	end
	return false
end
function GM:PlayerLoadout(ply)
	if ply:Team() == TEAM_ZOMBIES then
		ply:Infect(true)
		if ply:IsNemesis() then
			ply:MakeNemesis()
		end
	else
		ply:MakeHuman()
		if ply:IsSurvivor() then
			ply:MakeSurvivor()
		end
	end
end
function GM:PlayerSetModel(ply)
	local ModelToSet
	if ply:IsZombie() then
		if cvars.Bool("zp_admin_zombie_model", false) then
			ModelToSet = AdminZombiePlayerModel
		else
			ModelToSet = ply:GetZombieClass().PModel
		end
	else
		if cvars.Bool("zp_admin_human_model", false) then
			ModelToSet = AdminHumanPlayerModel
		else
			ModelToSet = ply:GetHumanClass().PModel
		end
	end
	ply:SetModel(ModelToSet)
	ply:SetupHands()
end
function GM:PlayerCanPickupWeapon(ply, wep)
	if(ply:IsZombie()) then
		return ply:ZombieCanUseWeapon(wep:GetClass())
	end

	return true
end
function GM:CanPlayerSuicide(ply)
	return false
end
function GM:PlayerShouldTaunt()
	return false
end
function FlashlightShouldDrain()
	return cvars.Bool("zp_battery_flashlight_should_drain", false) || RoundManager:IsRealisticMod()
end
function NightvisionShouldDrain()
	return cvars.Bool("zp_battery_nightvision_should_drain", false) || RoundManager:IsRealisticMod()
end
function VoiceShouldDrain()
	return cvars.Bool("zp_battery_voice_should_drain", false) || RoundManager:IsRealisticMod()
end
function WaterShouldDrain()
	return (RoundManager:IsRealisticMod() || cvars.Bool("zp_water_should_drain", 0))
end
function RunShouldDrain(ply)
	return ply:GetWalkSpeed() != ply:GetRunSpeed() && (RoundManager:IsRealisticMod() || cvars.Bool("zp_run_should_drain", 0))
end
timer.Create("TickManager", 0.1, 0, function()
	hook.Call("TickManager")
end)
timer.Create("HalfSecondTickManager", 0.5, 0, function()
	hook.Call("HalfSecondTickManager")
end)
timer.Create("SecondTickManager", 1, 0, function()
	hook.Call("SecondTickManager")
end)
net.Receive("RequestSpectator", function(len, ply)
	if ply:Team() != TEAM_SPECTATOR then
		RoundManager:RemovePlayerToPlay(ply)
		ply:KillSilent()
		ply:Spectate(OBS_MODE_ROAMING)
	else
		RoundManager:AddPlayerToPlay(ply)
	end
end)
net.Receive("RequestNightvision", function(len, ply)
	ToggleNightvision(ply)
end)
Commands:AddCommand("zp", "Open Zombie Plague's menu.", function(ply, args)
	net.Start("OpenZPMenu")
	net.Send(ply)
end)
hook.Add("SecondTickManager", "ZPHealthRegenerator", function()
	if cvars.Bool("zp_health_should_regen", true) then
		for k, ply in pairs(RoundManager:GetAliveZombies()) do
			if CurTime() - ply:GetLastDamage() > cvars.Number("zp_health_regen_time_delay", 20) && ply:Health() < ply:GetMaxHealth() then
				local TotalHealth = ply:Health() + cvars.Number("zp_health_regen", 10)
				ply:SetHealth((TotalHealth > ply:GetMaxHealth() and ply:GetMaxHealth() or TotalHealth))
			end
		end
	end
end)
hook.Add("SecondTickManager", "ZPAFKManager", function()
	for k, ply in pairs(RoundManager:GetAliveZombies()) do
		if CurTime() - ply:GetLastMove() > math.random(15, 30) then
			ply:ZPEmitSound(SafeTableRandom(ZombieIdle), 2, true)
			ply:SetLastMove(CurTime())
		end
	end
end)
hook.Add("HalfSecondTickManager", "ZPBreathManager", function()
	local TotalDrain
	for k, ply in pairs(RoundManager:GetPlayersToPlay()) do
		if ply:Alive() then
			TotalDrain = 0
			if WaterShouldDrain() && ply:WaterLevel() > 2 then
				TotalDrain = TotalDrain + cvars.Number("zp_water_drain", 1)
			end
			if RunShouldDrain(ply) && ply:KeyDown(IN_SPEED) && (ply:KeyDown(IN_FORWARD) || ply:KeyDown(IN_BACK) || ply:KeyDown(IN_MOVELEFT) || ply:KeyDown(IN_MOVERIGHT)) then
				TotalDrain = TotalDrain + cvars.Number("zp_run_drain", 1)
			end
			
			if TotalDrain > 0 then
				if ply:GetBreath() > 0 then
					ply:TakeBreath(TotalDrain)
				else
					hook.Call("ZPSuffocate", GAMEMODE, ply)
				end
			elseif ply:GetBreath() < ply:GetMaxBreath() then
				ply:AddBreath(cvars.Number("zp_breath_recover", 1))
			end
		end
	end
end)
hook.Add("ZPSuffocate", "ZPBreathDamage", function(ply)
	local DmgInfo = DamageInfo()
	DmgInfo:SetDamage(cvars.Number("zp_breath_damage", 5))
	DmgInfo:SetDamageType(DMG_DROWNRECOVER)
	ply:TakeDamageInfo(DmgInfo)

	ply:ScreenFade(SCREENFADE.IN, Color(255, 255, 255, 20), 0.3, 0)
	if ply:WaterLevel() > 2 then
		ply:ZPEmitSound(SafeTableRandom(ply:IsHuman() and HumanDrownSounds or ZombieDrownSounds), 1.0)
	else
		ply:ZPEmitSound(SafeTableRandom(ply:IsHuman() and HumanSuffocateSound or ZombieSuffocateSound), 1.0)
	end
end)
hook.Add("TickManager", "GravityManager", function()
	for k, ply in pairs(RoundManager:GetPlayersToPlay()) do
		if ply:GetGravity() != ply:GetAuxGravity() then
			ply:SetGravity(ply:GetAuxGravity())
		end
	end
end)
hook.Add("ZPCureEvent", "GetCuredEffect", function(ply)
	ply:ScreenFade(SCREENFADE.IN, Color(0, 0, 255, 128), 0.3, 0)
end)
hook.Add("TickManager", "DrainManager", function()
	local TotalDrain
	for k, ply in pairs(RoundManager:GetAliveHumans()) do
		TotalDrain = 0
		if FlashlightShouldDrain() && ply:FlashlightIsOn() then
			TotalDrain = TotalDrain + cvars.Number("zp_battery_flashlight_drain", 1)
		end
		if NightvisionShouldDrain() && ply:NightvisionIsOn() then
			TotalDrain = TotalDrain + cvars.Number("zp_battery_nightvision_drain", 2)
		end
		if VoiceShouldDrain() && ply:IsTalking() then
			TotalDrain = TotalDrain + cvars.Number("zp_battery_voice_drain", 0.5)
		end
		
		if TotalDrain > 0 then
			if ply:GetBattery() > 0 then
				ply:DrainBattery(TotalDrain)
			end
		elseif ply:GetBattery() < ply:GetMaxBatteryCharge() then
			ply:ChargeBattery(cvars.Number("zp_battery_charge", 0.5))
		end
	end
end)
hook.Add("SetupMove", "IdleManager", function(ply, mvd)
	if ply:Alive() then
		for k, key in pairs(MoveKeys) do
			if mvd:KeyDown(key) then
				ply:SetLastMove(CurTime())
			end
		end
	end
end)
hook.Add("PlayerBatteryOver", "ZPBatteryOver", function(ply)
	if ply:FlashlightIsOn() then
		ply:Flashlight(false)
	end
	if ply:NightvisionIsOn() then
		ply:SetNightvision(false)
	end
end)
hook.Add("ZPLastHumanEvent", "LastHumanHealth", function()
	local Mode = cvars.Number("zp_last_human_reward_mode", 0)
	local LastHuman = table.Random(RoundManager:GetAliveHumans())
	if Mode == 1 then
		LastHuman:SetHealth(LastHuman:Health() + (RoundManager:CountZombiesAlive() * cvars.Number("zp_last_human_reward_health", 10)))
	elseif Mode == 2 then
		LastHuman:SetHealth(LastHuman:Health() + cvars.Number("zp_last_human_reward_health", 10))
	end
end)
hook.Add("ZPLastZombieEvent", "LastZombieHealth", function()
	local Mode = cvars.Number("zp_last_zombie_reward_mode", 0)
	local LastZombie = table.Random(RoundManager:GetAliveZombies())
	if Mode == 1 then
		LastZombie:SetHealth(LastZombie:Health() + (RoundManager:CountHumansAlive() * cvars.Number("zp_last_zombie_reward_health", 250)))
	elseif Mode == 2 then
		LastZombie:SetHealth(LastZombie:Health() + cvars.Number("zp_last_zombie_reward_health", 25))
	end
end)

util.AddNetworkString("RequestSpectator")
util.AddNetworkString("RequestNightvision")