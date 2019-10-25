Commands = {CommandList = {}}

function Commands:AddCommand(Command, Description, Function, Help, Private)
	if (type(Command) != "table") then Command = {Command} end
	for k, Com in pairs(Command) do
		if !Commands.CommandList[Com] then
			Commands.CommandList[Com] = {Description = Description, Function = Function, Help = (Help and Help or "<NO ARGS>"), Private = Private}
		end
	end
end
Commands:AddCommand("commands", "Print the server's commands.", function(ply, args)
	SendColorMessage(ply, "Server's command list has been printed!", Color(255, 255, 0))
	local StringCommands = "--------------------------Commands--------------------------\n"
	for k, v in pairs(Commands.CommandList) do
		if v.Private == ply:IsSuperAdmin() then
			StringCommands = StringCommands .. k .. " - Sintax: /" .. k .. " " .. v['Description'] .. "\n"
		end
	end
	SendConsoleMessage(ply, StringCommands .. "------------------------------------------------------------")
end)
hook.Add("PlayerSay", "Commands", function(ply, txt, teste)
	local args = string.Explode(" ", string.lower(txt))
	if string.sub(args[1], 1, 1) == "/" || string.sub(args[1], 1, 1) == "!" then
		local Command = Commands.CommandList[string.sub(args[1], 2, string.len(args[1]))]
		table.remove(args, 1)
		if Command != nil then
			if args[1] == "help" || args[1] == "ajuda" then
				SendColorMessage(ply, "Help:\n" .. Command.Help, Color(255, 255, 0))
			else
				Command.Function(ply, args)
			end
			if Command.Private then
				return ""
			end
		end
	end
end)