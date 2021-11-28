ConvarManager = {Convars = {}}
function ConvarManager:CreateConVar(Convar, Value, CvarEnum, Description)
    CreateConVar(Convar, Value, CvarEnum, Description)

    ConvarManager.Convars[Convar] = Description
end

Commands:AddCommand("cvars", "List all cvars available for zombieplague", function(ply)
    local SortedTable = {}
    for k, Cvar in pairs(ConvarManager.Convars) do
        table.insert(SortedTable, {Name=k, Description=Cvar})
    end

    table.sort(SortedTable, function(CmdA, CmdB) return CmdA.Name < CmdB.Name end)

    SendConsoleMessage(ply, "Convars server list:")
    for k, Cvar in pairs(SortedTable) do
        SendConsoleMessage(ply, Cvar.Name .. " - " .. Cvar.Description)
    end

    SendColorMessage(ply, "ConVars has been printed on the console", Color(255, 255, 0))
end, "", true)

Commands:AddCommand("makecvarslist", "Make a list of all cvars available for zombieplague", ConvarManager.ListCvars, "", true)