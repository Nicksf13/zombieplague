ZOMBIE_KNIFE = "zp_weapon_fists"

INFECTION_BOMB = "weapon_frag"
INFECTION_BOMB_ENTITY = "npc_grenade_frag"

ALLOWED_PREFIX = {"zm_", "ze_", "zp_"}

AdminHumanPlayerModel = "models/player/combine_super_soldier.mdl"
AdminZombiePlayerModel = "models/player/zombie_soldier.mdl"

NemesisClass = {Health = 5000,
		Speed = 270,
		RunSpeed = 270,
		CrouchedSpeed = 0.7,
		Gravity = 0.5,
		Ability = false,
		PlayerModel = "models/player/zombie_soldier.mdl"
	}
SurvivorClass = {Health = 250,
		Speed = 270,
		RunSpeed = 230,
		CrouchedSpeed = 0.5,
		Gravity = 0.8,
		PlayerModel = "models/player/combine_super_soldier.mdl"
	}

---------------------------------Sounds---------------------------------
FallDamageSounds = {"zombieplague/zombie_fall1.mp3"} -- For Zombies
BurnDamageSounds = {"zombieplague/zombie_burn3.mp3",
	"zombieplague/zombie_burn4.mp3",
	"zombieplague/zombie_burn5.mp3",
	"zombieplague/zombie_burn6.mp3",
	"zombieplague/zombie_burn7.mp3"} -- For Zombies
	
GenericDamageSounds = {"npc/zombie/zombie_pain1.wav",
	"npc/zombie/zombie_pain2.wav",
	"npc/zombie/zombie_pain3.wav",
	"npc/zombie/zombie_pain5.wav",
	"npc/zombie/zombie_pain6.wav"} -- For Zombies

NemesisDamageSounds = {"zombieplague/nemesis_pain1.mp3",
	"zombieplague/nemesis_pain2.mp3",
	"zombieplague/nemesis_pain3.mp3"}

InfectionSounds = {"zombieplague/zombie_infec1.mp3",
	"zombieplague/zombie_infec2.mp3",
	"zombieplague/zombie_infec3.mp3"}
	
CureSounds = {"items/smallmedkit1.wav"}

HumanWinSounds = {"zombieplague/win_humans1.mp3",
	"zombieplague/win_humans2.mp3"}
	
ZombieWinSounds = {"zombieplague/win_zombies1.mp3",
	"zombieplague/win_zombies2.mp3",
	"zombieplague/win_zombies3.mp3"}
	
DrawSounds = {"ambient/atmosphere/cave_hit1.wav",
	"ambient/atmosphere/cave_hit2.wav",
	"ambient/atmosphere/cave_hit3.wav",
	"ambient/atmosphere/cave_hit4.wav",
	"ambient/atmosphere/cave_hit5.wav",
	"ambient/atmosphere/cave_hit6.wav"}

ZombieDeathSounds = {"npc/zombie/zombie_die1.wav",
	"npc/zombie/zombie_die2.wav",
	"npc/zombie/zombie_die3.wav",
	"npc/zombie/zombie_pain4.wav"}

ZombieIdle = {"zombieplague/zombie_brains1.mp3",
	"zombieplague/zombie_brains2.mp3"}
	
ZombieMadnessSounds = {"zombieplague/zombie_madness1.mp3"}
	
HumanTaunts = {}

HumanDrownSounds = {"player/pl_drown1.wav",
	"player/pl_drown2.wav",
	"player/pl_drown3.wav"}

ZombieDrownSounds = {"player/pl_drown1.wav",
"player/pl_drown2.wav",
"player/pl_drown3.wav"}

HumanSuffocateSound = {"player/pl_pain5.wav",
	"player/pl_pain6.wav",
	"player/pl_pain7.wav"}

ZombieSuffocateSound = {"player/pl_pain5.wav",
	"player/pl_pain6.wav",
	"player/pl_pain7.wav"}


UnfreezeSounds = {
	"radio/moveout.wav",
	"radio/locknload.wav",
	"radio/go.wav",
	"radio/com_go.wav"
}

NIGHTVISION_ON_SOUND = "zombieplague/nightvision.mp3"
NIGHTVISION_OFF_SOUND = "zombieplague/nightvision.mp3"

for k, SoundPath in pairs(ZombieKnifeSound) do
	resource.AddFile("sound/" .. SoundPath)
end
for k, SoundPath in pairs(ZombieMadnessSounds) do
	resource.AddFile("sound/" .. SoundPath)
end
for k, SoundPath in pairs(FallDamageSounds) do
	resource.AddFile("sound/" .. SoundPath)
end
for k, SoundPath in pairs(BurnDamageSounds) do
	resource.AddFile("sound/" .. SoundPath)
end
for k, SoundPath in pairs(GenericDamageSounds) do
	resource.AddFile("sound/" .. SoundPath)
end
for k, SoundPath in pairs(InfectionSounds) do
	resource.AddFile("sound/" .. SoundPath)
end
for k, SoundPath in pairs(CureSounds) do
	resource.AddFile("sound/" .. SoundPath)
end
for k, SoundPath in pairs(HumanWinSounds) do
	resource.AddFile("sound/" .. SoundPath)
end
for k, SoundPath in pairs(ZombieWinSounds) do
	resource.AddFile("sound/" .. SoundPath)
end
for k, SoundPath in pairs(DrawSounds) do
	resource.AddFile("sound/" .. SoundPath)
end
for k, SoundPath in pairs(ZombieDeathSounds) do
	resource.AddFile("sound/" .. SoundPath)
end
for k, SoundPath in pairs(HumanTaunts) do
	resource.AddFile("sound/" .. SoundPath)
end
for k, SoundPath in pairs(NemesisDamageSounds) do
	resource.AddFile("sound/" .. SoundPath)
end
for k, SoundPath in pairs(ZombieIdle) do
	resource.AddFile("sound/" .. SoundPath)
end
for k, SoundPath in pairs(HumanDrownSounds) do
	resource.AddFile("sound/" .. SoundPath)
end
for k, SoundPath in pairs(ZombieDrownSounds) do
	resource.AddFile("sound/" .. SoundPath)
end
for k, SoundPath in pairs(HumanSuffocateSound) do
	resource.AddFile("sound/" .. SoundPath)
end
for k, SoundPath in pairs(ZombieSuffocateSound) do
	resource.AddFile("sound/" .. SoundPath)
end

for k, SoundPath in pairs(UnfreezeSounds) do
	resource.AddFile("sound/" .. SoundPath)
end
resource.AddFile("sound/" .. NIGHTVISION_ON_SOUND)
resource.AddFile("sound/" .. NIGHTVISION_OFF_SOUND)

---------------------------------Sounds---------------------------------
-------------------------------Ammo Pack--------------------------------
ConvarManager:CreateConVar("zp_ap_total", 1, 8, "cvar used to set how many ammo packs humans will win after cause x damage.")
ConvarManager:CreateConVar("zp_ap_damage", 500, 8, "cvar used to set how much damage humans should cause to earn zp_ap_total ammo packs, set 0 to disable.")

ConvarManager:CreateConVar("zp_ap_zombies", 1, 8, "cvar used to set if Zombies should earn ammo packs when infected players.")
ConvarManager:CreateConVar("zp_ap_zombies_total", 1, 8, "cvar used to set the amount of ammo packs the zombie will win after infect a player.")

ConvarManager:CreateConVar("zp_ap_kill_human", 5, 8, "cvar used to set how many ammo packs player will win if killed an human.")
ConvarManager:CreateConVar("zp_ap_kill_zombie", 5, 8, "cvar used to set how many ammo packs player will win if killed a zombie.")
-------------------------------Ammo Pack--------------------------------
-----------------------------Point system-------------------------------
ConvarManager:CreateConVar("zp_point_damage_amount_to_point", 1500, 8, "cvar used to set how much damage humans should cause to earn zp_point_amount_received points, set 0 to disable.")
ConvarManager:CreateConVar("zp_point_amount_received", 1, 8, "cvar used to set how many points a human will receive after causing X damage.")
ConvarManager:CreateConVar("zp_point_points_per_zombie_kill", 1, 8, "cvar used to set how many points a human will receive after killing a zombie.")
ConvarManager:CreateConVar("zp_point_points_per_human_kill", 1, 8, "cvar used to set how many points a zombie will receive after killing a human.")
ConvarManager:CreateConVar("zp_point_points_per_infection", 1, 8, "cvar used to set how many points a zombie will receive after infecting a human.")
ConvarManager:CreateConVar("zp_point_points_per_cure", 1, 8, "cvar used to set how many points a human will receive after curing a zombie.")
ConvarManager:CreateConVar("zp_point_negative_points_per_suicide", 1, 8, "cvar used to set how many points someone who suicided will be penalized.")
-----------------------------Point system-------------------------------
---------------------------------Configs--------------------------------
ConvarManager:CreateConVar("zp_realistic_mode", 0, 8, "cvar used to set realistic mode on Zombie Plague.")

ConvarManager:CreateConVar("zp_nemesis_health_mode", 1, 8, "cvar used to set nemesis' health mode.")
ConvarManager:CreateConVar("zp_nemesis_health_player", 500, 8, "cvar used to set how much health nemesis will earn per player.")
ConvarManager:CreateConVar("zp_nemesis_health", 5000, 8, "cvar used to the health of nemesis.")
ConvarManager:CreateConVar("zp_nemesis_override_player_mode", 0, 8, "cvar used to set if nemesis' player model will be a fixed model")

ConvarManager:CreateConVar("zp_survivor_health_mode", 1, 8, "cvar used to set survivor's health mode.")
ConvarManager:CreateConVar("zp_survivor_health_player", 50, 8, "cvar used to set how much health survivor will earn per player.")
ConvarManager:CreateConVar("zp_survivor_health", 300, 8, "cvar used to the health of survivor.")
ConvarManager:CreateConVar("zp_survivor_override_player_mode", 0, 8, "cvar used to set if survivor's player model will be a fixed model")

ConvarManager:CreateConVar("zp_zombie_footstep", 1, 8, "cvar used to set if zombies will emit footstep sounds.") 
ConvarManager:CreateConVar("zp_zombie_screen_filter", 1, 8, "cvar used to set if zombie will have a \"red\" effect in his screen")

ConvarManager:CreateConVar("zp_admin_human_model", 0, 8, "cvar used to set if admin will receive a special human player model.")
ConvarManager:CreateConVar("zp_admin_zombie_model", 0, 8, "cvar used to set if admin will receive a special zombie player model.")

ConvarManager:CreateConVar("zp_voice_all", 1, 8, "cvar used to set if players will hear other team players.")
ConvarManager:CreateConVar("zp_can_hear_death", 1, 8, "cvar used to set if players will hear death players")
ConvarManager:CreateConVar("zp_chat_all", 1, 8, "cvar used to set if players will read other team players.")
ConvarManager:CreateConVar("zp_can_see_death", 1, 8, "cvar used to set if players will read death players")

ConvarManager:CreateConVar("zp_maps_to_vote", 7, 8, "cvar used to set how many maps will be displayed on votemap")
ConvarManager:CreateConVar("zp_map_prop_damage_multiplier", 1, 8, "cvar used to set the map prop multiplier")

ConvarManager:CreateConVar("zp_nemesis_earn", 0, 8, "cvar used to set if nemesis will earn class atributes")
ConvarManager:CreateConVar("zp_survivor_earn", 0, 8, "cvar used to set if survivor will earn class atributes")