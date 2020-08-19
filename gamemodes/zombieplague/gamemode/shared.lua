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
include("sh_playermanager.lua")

--
-- config
--

ZombiePlague_mk2 = ZombiePlague_mk2 or {}
ZombiePlague_mk2.config = {
	serverName = "Zombie Plague server",
	serverPassword = "",
	serverLoadingURL = "",

	serverRunCommands = {
		"net_maxfilesize 64",
	},
	
	-- https://i.imgur.com/MMEm7c6.png
	serverFastDL = {
		"maps/zm_street.bsp", -- 5mb
		
		"sound/zombieplague/knife_slash1.mp3",
		"sound/zombieplague/knife_slash2.mp3",
		"sound/zombieplague/nemesis_pain1.mp3",
		"sound/zombieplague/nemesis_pain2.mp3",
		"sound/zombieplague/nemesis_pain3.mp3",
		"sound/zombieplague/nemesis1.mp3",
		"sound/zombieplague/nemesis2.mp3",
		"sound/zombieplague/nightvision.mp3",
		"sound/zombieplague/survivor1.mp3",
		"sound/zombieplague/survivor2.mp3",
		"sound/zombieplague/win_humans1.mp3",
		"sound/zombieplague/win_humans2.mp3",
		"sound/zombieplague/win_zombies1.mp3",
		"sound/zombieplague/win_zombies2.mp3",
		"sound/zombieplague/win_zombies3.mp3",
		"sound/zombieplague/zombie_brains1.mp3",
		"sound/zombieplague/zombie_brains2.mp3",
		"sound/zombieplague/zombie_burn3.mp3",
		"sound/zombieplague/zombie_burn4.mp3",
		"sound/zombieplague/zombie_burn5.mp3",
		"sound/zombieplague/zombie_burn6.mp3",
		"sound/zombieplague/zombie_burn7.mp3",
		"sound/zombieplague/zombie_fall1.mp3",
		"sound/zombieplague/zombie_infec1.mp3",
		"sound/zombieplague/zombie_infec2.mp3",
		"sound/zombieplague/zombie_infec3.mp3",
		"sound/zombieplague/zombie_madness1.mp3"
	}
}

if SERVER then
	function ZombiePlague_mk2.loadConfig()
		local data = ZombiePlague_mk2.config

		RunConsoleCommand( "hostname", data.serverName )
		RunConsoleCommand( "sv_password", data.serverPassword )
		RunConsoleCommand( "sv_loadingurl", data.serverLoadingURL )

		for _, entry in pairs( data.serverRunCommands ) do
			local args = string.Explode( " ", entry )
			local cmd = table.remove( args, 1 )

			RunConsoleCommand( cmd, unpack( args ) )
		end

		for k, v in ipairs( data.serverFastDL ) do
			resource.AddSingleFile(v)
		end
	end

	function GM:InitPostEntity()
		ZombiePlague_mk2.loadConfig();
	end
end