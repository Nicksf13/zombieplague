Commands = {CommandList = {}}

function Commands:AddCommand(Command, Description, Function, Help, Private, PermissionFunction)
	if (type(Command) != "table") then Command = {Command} end
	for k, Com in pairs(Command) do
		if !Commands.CommandList[Com] then
			Commands.CommandList[Com] = {
				Description = Description,
				Function = Function,
				Help = (Help and Help or ""),
				Private = Private,
				PermissionFunction = PermissionFunction
			}
		end
	end
end
Commands:AddCommand("commands", "Print the server's commands.", function(ply, args)
	SendColorMessage(ply, "Server's command list has been printed!", Color(255, 255, 0))
	local StringCommands = "--------------------------Commands--------------------------\n"
	for k, v in pairs(Commands.CommandList) do
		if v.Private then
			if ply:IsSuperAdmin() then
				StringCommands = StringCommands .. k .. " - Description: " .. v.Description .. " - Sintax: /" .. k .. " " .. v.Help .. "\n"
			end
		else
			StringCommands = StringCommands .. k .. " - Description: " .. v.Description .. " - Sintax: /" .. k .. " " .. v.Help .. "\n"
		end
	end
	SendConsoleMessage(ply, StringCommands .. "------------------------------------------------------------")
end)
if BOT_MODE then
	Commands:AddCommand("bot", "Add a bot to the server", function(ply, args)
		RunConsoleCommand("bot")

		timer.Create("bot", 1, 1, function()
			local PlayersToPlay = RoundManager:GetPlayersToPlay()
			for k, Bot in pairs(player.GetBots()) do
				if !table.HasValue(PlayersToPlay, Bot) then
					RoundManager:AddPlayerToPlay(Bot)
				end
			end
		end)
	end, "", true, function(ply) return ply:IsSuperAdmin() end)
end
hook.Add("PlayerSay", "Commands", function(ply, txt)
	local args = string.Explode(" ", string.lower(txt))
	if string.sub(args[1], 1, 1) == "/" || string.sub(args[1], 1, 1) == "!" then
		local Command = Commands.CommandList[string.sub(args[1], 2, string.len(args[1]))]
		table.remove(args, 1)
		if Command then
			if args[1] == "help" || args[1] == "ajuda" then
				SendColorMessage(ply, "Help:\n" .. Command.Help, Color(255, 255, 0))
			else
				if(!Command.PermissionFunction || Command.PermissionFunction(ply)) then
					Command.Function(ply, args)
				else
					SendPopupMessage(ply, Dictionary:GetPhrase("CommandNotAccess", ply))
				end
			end
			if Command.Private then
				return ""
			end
		end
	end
end)