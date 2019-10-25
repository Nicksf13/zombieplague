MapManager = {Configs = {}}

function MapManager:SearchConfigs()
	local Files = file.Find("zombieplague/gamemode/mapconfigs/*.lua", "LUA")
	if Files then
		for k, File in pairs(Files) do
			MapConfig = {}
			include("zombieplague/gamemode/mapconfigs/" .. File)
			
			if (MapConfig.Prefix || MapConfig.MapName) && MapConfig.Start then
				MapManager:AddMapConfig(MapConfig)
			else
				print("Invalid map config: '" .. File .. "'.")
			end
		end
	end
end
function MapManager:AddMapConfig(MapConfig)
	table.insert(MapManager.Configs, MapConfig)
end
function MapManager:GetMapConfig(MapName)
	for k, MapConfig in pairs(MapManager.Configs) do
		if MapConfig.MapName == MapName then
			return MapConfig
		end
	end
	for k, MapConfig in pairs(MapManager.Configs) do
		if MapConfig.Prefix && string.StartWith(MapName, MapConfig.Prefix) then
			return MapConfig
		end
	end
	return nil
end
hook.Add("ZPPrePreparingRound", "LoadMapConfig", function(RoundToStart)
	local SetupConfig = MapManager:GetMapConfig(game.GetMap())
	if SetupConfig then
		SetupConfig:Start(RoundToStart)
	end
end)