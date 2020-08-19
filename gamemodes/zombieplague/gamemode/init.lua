BOT_MODE = true

include("shared.lua")
include("sv_commands.lua")
include("sv_convar.lua")
include("sv_config.lua")
include("sv_player.lua")
include("sv_language.lua")
include("sv_message.lua")
include("sv_classmanager.lua")
include("sv_roundmanager.lua")
include("sv_eventmanager.lua")
include("sv_infectionmanager.lua")
include("sv_weaponmanager.lua")
include("sv_extraitems.lua")
include("sv_votemap.lua")
include("sv_mapmanager.lua")
include("sv_bank.lua")

AddCSLuaFile("shared.lua")
AddCSLuaFile("sh_bank.lua")
AddCSLuaFile("sh_roundmanager.lua")
AddCSLuaFile("sh_player.lua")
AddCSLuaFile("sh_playermanager.lua")
AddCSLuaFile("cl_hud.lua")
AddCSLuaFile("cl_language.lua")
AddCSLuaFile("cl_message.lua")
AddCSLuaFile("cl_player.lua")
AddCSLuaFile("cl_roundmanager.lua")
AddCSLuaFile("cl_menu.lua")
AddCSLuaFile("cl_keymanager.lua")
AddCSLuaFile("cl_derma.lua")
AddCSLuaFile("cl_scoreboard.lua")
AddCSLuaFile("zombieplague/gamemode/vgui/vgui_keybinding.lua")
AddCSLuaFile("zombieplague/gamemode/vgui/vgui_hudcustomizer.lua")

-- Micro-optimisation
local RoundManager = RoundManager
local Dictionary = Dictionary
local hook = hook
local ClassManager = ClassManager
local WeaponManager = WeaponManager
local ExtraItemsManager = ExtraItemsManager
local MapManager = MapManager

function SafeTableRandom(Table)
	local Result = table.Random(Table)
	return Result
end

hook.Add("PlayerDisconnected", "ZombiePlagueDisconnect", function(ply)
	RoundManager:RemovePlayerToPlay(ply)
end)

hook.Add("Initialize", "ServerReady", function()
	Dictionary:Init()
	ClassManager:SearchClasses()
	RoundManager:SearchRounds()
	WeaponManager:SearchWeapons()
	ExtraItemsManager:Search()
	MapManager:SearchConfigs()
end)

net.Receive("RequestServerStatus", function(len, ply)
	ply:SetLanguage(net.ReadString(), false)
	RoundManager:AddPlayerToPlay(ply)
	
	local Status = RoundManager:GetServerStatus(ply)
	net.Start("SendServerStatus")
		net.WriteTable(Status)
	net.Send(ply)
end)

util.AddNetworkString("OpenZPMenu")
util.AddNetworkString("RequestServerStatus")
util.AddNetworkString("SendServerStatus")
util.AddNetworkString("OpenBackMenu")