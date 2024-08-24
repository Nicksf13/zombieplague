EntityManager = {
    MappedButtons = {}
}

Commands:AddCommand("edit", "Start entities editing", function(Ply, Args)
	RunConsoleCommand("nav_edit", 1)
    
    local EntitiesOfInteress = {}

    for K, SpawnHuman in pairs(team.GetSpawnPoints(TEAM_HUMANS)) do
        table.insert(EntitiesOfInteress, SpawnHuman)
    end
    for K, SpawnZombies in pairs(team.GetSpawnPoints(TEAM_ZOMBIES)) do
        table.insert(EntitiesOfInteress, SpawnZombies)
    end

    local PrettyEntities = {}
    
    for K, Entity in pairs(EntitiesOfInteress) do
        table.insert(PrettyEntities, {
            Pos = Entity:GetPos(),
            Angles = Entity:GetAngles(),
            Class = Entity:GetClass()
        })
    end

    print("Mandando entidades")
    net.Start("StartEditing")
        net.WriteTable(PrettyEntities)
    net.Send(Ply)
end)

hook.Add("EntityKeyValue", "MapEntitiesOnEvents", function( Ent, Key, Value)
    if Ent:GetClass() == "func_button" && string.Left(Key, 2) == "On" then
        local Properties = string.Explode(",", Value)
        local ButtonInformation = {
            ButtonEntity = Ent,
            TargetName = Properties[1]
        }
        
        table.insert(EntityManager.MappedButtons, ButtonInformation)
    end
end)

util.AddNetworkString("StartEditing")