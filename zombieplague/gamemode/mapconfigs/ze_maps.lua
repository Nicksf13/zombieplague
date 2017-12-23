MapConfig.Prefix = "ze_"
MapConfig.Start = function()
	RunConsoleCommand("zp_map_prop_damage_multiplier", 2)
	RunConsoleCommand("zp_round_time", 450)
	RunConsoleCommand("sv_gravity", 450)
end