CreateConVar("zp_falldamage", 1, 8, "cvar used to set fall damage for players")
CreateConVar("zp_nemesis_damage", 10, 8, "cvar used to set how stronger nemesis will be.")
CreateConVar("zp_survivor_damage", 1.1, 8, "cvar used to set how stronger survivor will be.")
CreateConVar("zp_battery_flashlight_should_drain", 0, "cvar used to set if flashlight should drain battery")
CreateConVar("zp_battery_flashlight_drain", 1, 8, "cvar used to set flashlight battery drain")
CreateConVar("zp_battery_nightvision_should_drain", 0, "cvar used to set if nightvision should drain battery")
CreateConVar("zp_battery_nightvision_drain", 1, 8, "cvar used to set nightvision battery drain")
CreateConVar("zp_battery_voice_should_drain", 0, "cvar used to set if voice should drain battery")
CreateConVar("zp_battery_voice_drain", 1, 8, "cvar used to set voice battery drain")
CreateConVar("zp_battery_charge", 0.5, 8, "cvar use to set battery recharge")
CreateConVar("zp_breath_drain", 1, 8, "cvar used to set breath drain")
CreateConVar("zp_breath_damage", 1, 8, "cvar used to set breath damage")
CreateConVar("zp_breath_recover", 0.5, 8, "cvar used to set breath recover")
CreateConVar("zp_last_human_reward_mode", 1, 8, "cvar used to set last human reward")
CreateConVar("zp_last_human_reward_health", 25, 8, "cvar used to set last human health reward")
CreateConVar("zp_last_zombie_reward_mode", 1, 8, "cvar used to set last zombie reward")
CreateConVar("zp_last_zombie_reward_health", 250, 8, "cvar used to set last zombie health reward")
CreateConVar("zp_health_should_regen", 1, 8, "cvar used to set if zombies will regen health.")
CreateConVar("zp_health_regen_time_delay", 20, 8, "cvar used to set the delay time after last damage to regen zombie's health.")
CreateConVar("zp_health_regen", 10, 8, "cvar used to set how much health zombies will regen.")

FALL_DMG_NONE = 0
FALL_DMG_ZOMBIES = 1
FALL_DMG_HUMANS = 2
FALL_DMG_ALL = 3

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
		local DamageMultiplier = WeaponManager:GetWeaponMultiplier(Attacker:GetActiveWeapon():GetClass())
		if DamageMultiplier then
			dmginfo:ScaleDamage(DamageMultiplier)
		end
		if Attacker:IsNemesis() then
			dmginfo:ScaleDamage(cvars.Number("zp_nemesis_damage",  10))
		elseif Attacker:IsSurvivor() then
			dmginfo:ScaleDamage(cvars.Number("zp_survivor_damage",  2))
		end
	end
	if target:IsPlayer() then
		if !RoundManager:IsRealisticMod() && !RoundManager:GetRoundState() == ROUND_PLAYING then
			return true
		end
		if Attacker:IsPlayer() then
			if target:Team() != Attacker:Team() then
				if Attacker:IsZombie() then
					local Damage = target:TakeArmorDamage(dmginfo:GetDamage())
					if Damage > 0 then
						if !RoundManager:IsSpecialRound() then
							if !RoundManager:LastHuman() then
								InfectionManager:Infect(target, Attacker)
							else
								dmginfo:SetDamage(Damage)
							end
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
function GM:PlayerFootstep(ply)
	return !ply:ShouldEmitFootStep()
end
function GM:AllowPlayerPickup(ply, item)
	return false
end
function GM:ShowSpare1(ply)
	if ply:GetBattery() > 0 then
		ply:SetNightvision(!ply:NightvisionIsOn())
	end
end
function GM:ShowSpare2(ply)
	net.Start("OpenZPMenu")
	net.Send(ply)
end
function GM:PlayerDeathSound()
	return true
end
function GM:PlayerCanHearPlayersVoice(listener, talker)
	return ShouldListenerHearTalker(listener, talker)
end
function GM:PlayerCanSeePlayersChat(txt, teamtalk, listener, talker)
	return ShouldListenerHearTalker(listener, talker)
end
function GM:PlayerSpawn(ply)
	if ply.FirstSpawn != nil then
		if ply:Team() != TEAM_SPECTATOR then
			if !PlayerCanSpawn(ply) then
				return true
			end
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
	CalculateSpectator(ply)
	return false
end
function CalculateSpectator(ply)
	local PlayersToObserve
	if RoundManager:IsRealisticMod() then
		if ply:IsZombie() then
			PlayersToObserve = RoundManager:GetAliveZombies()
		else
			PlayersToObserve = RoundManager:GetAliveHumans()
		end
	else
		PlayersToObserve = RoundManager:GetPlayersToPlay(true)
	end
	if #PlayersToObserve > 0 then
		if ply:GetObserverTarget() == nil || !ply:GetObserverTarget():IsPlayer() || !ply:GetObserverTarget():Alive() then
			ply:MoveSpectateID(0, PlayersToObserve)
		else
			if ply:KeyPressed(IN_JUMP) then
				ply:Spectate(((ply:GetObserverMode() + 1) % 3) + 4)
			elseif ply:KeyPressed(IN_ATTACK) then
				ply:MoveSpectateID(1, PlayersToObserve)
			elseif ply:KeyPressed(IN_ATTACK2) then
				ply:MoveSpectateID(-1, PlayersToObserve)
			end
		end
		PlayersToObserve = nil
	elseif ply:GetObserverMode() != OBS_MODE_ROAMING then
		ply:Spectate(OBS_MODE_ROAMING)
	end
end
function ShouldListenerHearTalker(Listener, Talker)
	if cvars.Bool("zp_realistic_mode", false) || !cvars.Bool("zp_voice_all", true) then
		return Listener:Team() == Talker:Team()
	end
	if !cvars.Bool("zp_can_hear_death", true) then
		if !Listener:Alive() then
			return true
		else
			return Talker:Alive()
		end
	end
	return true
end
hook.Add("PlayerDeath", "ZPPlayerDeath", function(ply, wep, killer)
	ply:SetPrimaryWeaponGiven(false)
	ply:SetSecondaryWeaponGiven(false)
	ply:SetLight(nil)
	if ply:IsZombie() then
		ply:EmitSound(SafeTableRandom(ZombieDeathSounds))
		if RoundManager:LastZombie() then
			hook.Call("ZPLastZombieEvent")
		end
		if killer:IsPlayer() then
			killer:AddAmmoPacks(cvars.Number("zp_ap_kill_zombie", 5))
		end
	else
		if RoundManager:LastHuman() then
			hook.Call("ZPLastHumanEvent")
		end
		if killer:IsPlayer() then
			killer:AddAmmoPacks(cvars.Number("zp_ap_kill_zombie", 5))
		end
	end
	
	ply:Spectate(OBS_MODE_CHASE)
	ply:SpectateEntity(killer)
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
		ply:Infect()
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
	if ply:IsZombie() then
		return ply:ZombieCanUseWeapon(wep:GetClass())
	end
	return true
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
timer.Create("TickManager", 0.1, 0, function()
	hook.Call("TickManager")
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
hook.Add("TickManager", "GravityManager", function()
	for k, ply in pairs(RoundManager:GetPlayersToPlay()) do
		if ply:GetGravity() != ply:GetAuxGravity() then
			ply:SetGravity(ply:GetAuxGravity())
		end
	end
end)
hook.Add("ZPInfectionEvent", "GetInfectedEffect", function(ply)
	ply:ScreenFade(SCREENFADE.IN, Color(0, 255, 0, 128), 0.3, 0)
end)
hook.Add("ZPCureEvent", "GetCuredEffect", function(ply)
	ply:ScreenFade(SCREENFADE.IN, Color(0, 0, 255, 128), 0.3, 0)
end)
hook.Add("TickManager", "DrainManager", function()
	local TotalDrain = 0
	for k, ply in pairs(RoundManager:GetPlayersToPlay(true)) do
		TotalDrain = 0
		if ply:Alive() && ply:IsHuman() then
			if FlashlightShouldDrain() && ply:FlashlightIsOn() then
				TotalDrain = TotalDrain + cvars.Number("zp_battery_flashlight_drain", 1)
			end
			if NightvisionShouldDrain() && ply:NightvisionIsOn() then
				TotalDrain = TotalDrain + cvars.Number("zp_battery_nightvision_drain", 2)
			end
			if VoiceShouldDrain() && ply:IsTalking() then
				TotalDrain = TotalDrain + cvars.Number("zp_battery_voice_drain", 0.5)
			end
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
	local LastHuman = RoundManager:GetAliveHumans()[1]
	if Mode == 1 then
		LastHuman:SetHealth(LastHuman:Health() + (RoundManager:CountZombiesAlive() * cvars.Number("zp_last_human_reward_health", 25)))
	elseif Mode == 2 then
		LastHuman:SetHealth(LastHuman:Health() + cvars.Number("zp_last_human_reward_health", 25))
	end
end)
hook.Add("ZPLastZombieEvent", "LastZombieHealth", function()
	local Mode = cvars.Number("zp_last_zombie_reward_mode", 0)
	local LastZombie = RoundManager:GetAliveZombies()[1]
	if Mode == 1 then
		LastZombie:SetHealth(LastZombie:Health() + (RoundManager:CountHumansAlive() * cvars.Number("zp_last_zombie_reward_health", 250)))
	elseif Mode == 2 then
		LastZombie:SetHealth(LastZombie:Health() + cvars.Number("zp_last_zombie_reward_health", 25))
	end
end)

util.AddNetworkString("RequestSpectator")