GM.Name 	= "Zombie Plague (For GMOD)"
GM.Author 	= "The Fire Fuchs (Original Author: MeRcyLeZZ)"
GM.Email 	= ""
GM.Website 	= ""

TEAM_HUMANS = 3
TEAM_ZOMBIES = 2

ZOMBIES_WIN = 1
HUMANS_WIN = 2
ROUND_DRAW = 3

ROUND_WAITING_PLAYERS = 0
ROUND_STARTING_NEW_ROUND = 1
ROUND_PLAYING = 2
ROUND_ENDING = 3
ROUND_RESTARTING = 4
ROUND_VOTEMAP = 5
ROUND_CHANGING_MAP = 6

NIGHTVISION_COLOR = Color(0, 255, 0)
NEMESIS_COLOR = Color(255, 0, 0)
SURVIVOR_COLOR = Color(0, 0, 255)

ZombieKnifeSound = {"zombieplague/knife_slash1.mp3", "zombieplague/knife_slash2.mp3"}

function GM:CreateTeams()
	team.SetUp(TEAM_HUMANS, "Humans", Color(71, 141, 255, 255), false)
	team.SetUp(TEAM_ZOMBIES, "Zombies", Color(255, 56, 56, 255), false)

	team.SetSpawnPoint(TEAM_ZOMBIES, "info_player_terrorist")
	team.SetSpawnPoint(TEAM_HUMANS, "info_player_counterterrorist")

	team.SetColor(TEAM_SPECTATOR, Color(0, 255, 0))
end

include("sh_roundmanager.lua")
include("sh_player.lua")
include("sh_bank.lua")