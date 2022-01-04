MapConfig.Prefix = "ze_"
MapConfig.Start = function()
	RunConsoleCommand("zp_map_prop_damage_multiplier", 2)
	RunConsoleCommand("zp_round_time", 450)
	RunConsoleCommand("sv_gravity", 450)

	hook.Add("ZPNewRound", "ze_zombie_respawn", function()
		for i, ply in ipairs(RoundManager:GetAliveZombies()) do
			ply:Spawn()
		end
	end)
end