local NumpadKeys = {
	KEY_1,
	KEY_2,
	KEY_3,
	KEY_4,
	KEY_5,
	KEY_6,
	KEY_7,
	KEY_8,
	KEY_9,
	KEY_0,
}
MMenu = {Options = {}, Page = 1, NetworkString = "", LastPress = 0}

function CreateMenu()
	MMenu.ZPOptions = {Options = {}}
	
	function MMenu.ZPOptions:AddLine(Description, PressFunction, PressKey)
		local Option = {
			Description = Description,
			PressFunction = PressFunction,
			PressKey = PressKey
		}
		table.insert(MMenu.ZPOptions.Options, Option)
	end
	function MMenu.ZPOptions:Clear()
		MMenu.ZPOptions.Options = {}
		MMenu.ZPOptions.BiggestTextSize = 0
	end

	function MMenu:UpdateOptions(Options)
		if table.Count(Options) > 0 then
			MMenu.Options = Options
			
			MMenu:SetPage(1)
			
			hook.Add("SetupMove", "ZPMenuKeyListener", function(ply, mvd)
				for k, Option in pairs(MMenu.ZPOptions.Options) do
					if input.WasKeyPressed(Option.PressKey) && MMenu.LastPress < CurTime() then
						Option:PressFunction(7 * (MMenu.Page - 1) + k)
						MMenu.LastPress = CurTime() + 0.1
						break
					end
				end
			end)
		else
			notification.AddLegacy(Dictionary:GetPhrase("MenuNoOptionsAvailableNow"), NOTIFY_GENERIC, 5)
		end
	end

	function MMenu:SetPage(Page)
		hook.Remove("HUDPaint", "ChooseMenu")
		MMenu.Page = Page
		MMenu.ZPOptions:Clear()
		
		local PgJump = 7 * (MMenu.Page - 1)
		local i = 1
		while(i < 8 && MMenu.Options[PgJump + i]) do
			MMenu.ZPOptions:AddLine(i .. " - " .. MMenu.Options[PgJump + i].Name, MMenu.Options[PgJump + i].Function, NumpadKeys[i])
			i = i + 1
		end
		
		if MMenu.Page > 1 then
			MMenu.ZPOptions:AddLine(
				"8 - " .. Dictionary:GetPhrase("MenuBack"), 
				function()
					MMenu:SetPage(MMenu.Page - 1)
				end,
				NumpadKeys[8]
			)
		end
		
		if MMenu.Page < table.Count(MMenu.Options) / 7 then
			MMenu.ZPOptions:AddLine(
				"9 - " .. Dictionary:GetPhrase("MenuNext"), 
				function()
					MMenu:SetPage(MMenu.Page + 1)
				end,
				NumpadKeys[9]
			)
		end

		MMenu.ZPOptions:AddLine(
			"0 - " .. Dictionary:GetPhrase("MenuClose"), 
			function()
				MMenu.ZPOptions.PressFunctions = {}
				MMenu.ZPOptions:Clear()
				hook.Remove("SetupMove", "ZPMenuKeyListener")
				hook.Remove("HUDPaint", "ChooseMenu")
			end,
			NumpadKeys[10]
		)

		hook.Add("HUDPaint", "ChooseMenu", function()
			local MenuOptions = HudManager:GetComponentConfig("Menu")
			local SizePerOption = 20
			local TotalOptions = table.Count(MMenu.ZPOptions.Options)

			surface.SetFont(MenuOptions.Font)
			local BiggestTextSize = 0

			for i, Option in pairs(MMenu.ZPOptions.Options) do
				local TextSize = surface.GetTextSize(Option.Description)

				if TextSize > BiggestTextSize then
					BiggestTextSize = TextSize
				end
			end

			local Width = BiggestTextSize + 20
			local Height = ((TotalOptions * SizePerOption) + 15)
			local XPos, YPos = HudManager:CalculatePos(MenuOptions.XPos, MenuOptions.YPos, Width, Height, 20, 20)

			HudManager:CreateBox(2, 10, MenuOptions.Border, MenuOptions.Body, XPos, YPos - 10, Width, Height)
			
			for i, Option in pairs(MMenu.ZPOptions.Options) do
				draw.DrawText(Option.Description, MenuOptions.Font, XPos + 10, YPos + ((i - 1) * SizePerOption), MenuOptions.Text, TEXT_ALIGN_LEFT)
			end
		end)
	end
end
function OpenZPMenu()
	local Options = {}
	table.insert(Options, {Order = 1, Name = Dictionary:GetPhrase("MenuZombieChoose"), Function = function() net.Start("RequestZombieMenu") net.SendToServer() hook.Remove("SetupMove", "ZPMenuKeyListener") hook.Remove("HUDPaint", "ChooseMenu") end})
	table.insert(Options, {Order = 2, Name = Dictionary:GetPhrase("MenuHumanChoose"), Function = function() net.Start("RequestHumanMenu") net.SendToServer() hook.Remove("SetupMove", "ZPMenuKeyListener") hook.Remove("HUDPaint", "ChooseMenu") end})
	table.insert(Options, {Order = 3, Name = Dictionary:GetPhrase("MenuWeaponChoose"), Function = function() net.Start("RequestWeaponMenu") net.SendToServer() hook.Remove("SetupMove", "ZPMenuKeyListener") hook.Remove("HUDPaint", "ChooseMenu") end})
	table.insert(Options, {Order = 4, Name = Dictionary:GetPhrase("MenuExtraItemChoose"), Function = function() net.Start("RequestExtraItemMenu") net.SendToServer() hook.Remove("SetupMove", "ZPMenuKeyListener") hook.Remove("HUDPaint", "ChooseMenu") end})
	table.insert(Options, {Order = 5, Name = Dictionary:GetPhrase("MenuLanguageChoose"), Function = function() net.Start("RequestLanguageMenu") net.SendToServer() hook.Remove("SetupMove", "ZPMenuKeyListener") hook.Remove("HUDPaint", "ChooseMenu") end})
	table.insert(Options, {Order = 6, Name = (LocalPlayer():Team() != TEAM_SPECTATOR and Dictionary:GetPhrase("MenuSpectator") or Dictionary:GetPhrase("MenuNonSpectator")), Function = function() net.Start("RequestSpectator") net.SendToServer() hook.Remove("SetupMove", "ZPMenuKeyListener") hook.Remove("HUDPaint", "ChooseMenu")end})
	if LocalPlayer():IsAdmin() || LocalPlayer():IsSuperAdmin() then
		table.insert(Options, {
			Order = 7,
			Name = Dictionary:GetPhrase("MenuAdmin"),
			Function = function()
				local AdminOptions = {}
				if RoundManager:GetRoundState() == ROUND_STARTING_NEW_ROUND then
					table.insert(AdminOptions, 
						GenerateMenuOption(
							Dictionary:GetPhrase("MenuAdminRoundChoose"),
							function()
								net.Start("RequestRoundsMenu")
								net.SendToServer()
							end
						)
					)
				end

				--if LocalPlayer():IsSuperAdmin() && cvars.Bool("zp_givetake_ammopacks_allowed", true) then
				--	table.insert(AdminOptions,
				--		GenerateMenuOption(
				--			Dictionary:GetPhrase("MenuAdminGiveAmmoPacks"),
				--			function()
				--				local AmmoPacksGiveOptions = {}
				--				for k, ply in pairs(player.GetAll()) do
				--				--table.insert(AmmoPacksGiveOptions,
				--				--	GenerateMenuOption(ply:GetName(), function()
				--				--		local AmountOptions = {}
				--				--		local GiveFunction = function(Amount)
				--				--			net.Start("GiveTakeAmmoPack")
				--				--				net.WriteString(ply:SteamID64())
				--				--				net.WriteBool(true)
				--				--				net.WriteInt(Amount, 64)
				--				--			net.SendToServer()
				--				--		end
----
				--				--		table.insert(AmountOptions,
				--				--			GenerateMenuOption("5", function()
				--				--				GiveFunction(5)
				--				--			end)
				--				--		)
				--				--		table.insert(AmountOptions,
				--				--			GenerateMenuOption("10", function()
				--				--				GiveFunction(10)
				--				--			end)
				--				--		)
				--				--		table.insert(AmountOptions,
				--				--			GenerateMenuOption("25", function()
				--				--				GiveFunction(25)
				--				--			end)
				--				--		)
				--				--		table.insert(AmountOptions,
				--				--			GenerateMenuOption("50", function()
				--				--				GiveFunction(50)
				--				--			end)
				--				--		)
				--				--		table.insert(AmountOptions,
				--				--			GenerateMenuOption("100", function()
				--				--				GiveFunction(100)
				--				--			end)
				--				--		)
				--				--		table.insert(AmountOptions,
				--				--			GenerateMenuOption("500", function()
				--				--				GiveFunction(5)
				--				--			end)
				--				--		)
----
				--				--		MMenu:UpdateOptions(AmountOptions)
				--				--	)
				--				--)
				--				end
				--				MMenu:UpdateOptions(AmmoPacksGiveOptions)
				--			end
				--		)
				--	)
				--end

				MMenu:UpdateOptions(AdminOptions)
			end
		})
	end
	table.insert(Options, {
		Name = Dictionary:GetPhrase("MenuCredit"),
		Function = function()
			gui.OpenURL("https://github.com/Nicholas-Fuchs/zombieplague/blob/develop/credits.md")
		end,
		Order = 1000
	})
	table.insert(Options, GenerateMenuOption(
		Dictionary:GetPhrase("MenuOptions"),
		function()
			OptionMenu:CreateOptionsMenu()
		end,
		999
	))
	
	MMenu:UpdateOptions(Options)
end
function GenerateMenuOption(Name, Function, Order)
	return {
		Name = Name,
		Function = function(ID)
			Function(ID)
			hook.Remove("SetupMove", "ZPMenuKeyListener")
			hook.Remove("HUDPaint", "ChooseMenu")
		end,
		Order = Order
	}
end
net.Receive("OpenZPMenu", OpenZPMenu)
net.Receive("OpenBackMenu", function()
	MMenu.NetworkString = net.ReadString()
	local ReceivedOptions = net.ReadTable()
	
	local MenuOptions = {}

	for ID, ReceivedOption in pairs(ReceivedOptions) do
		local Description = ReceivedOption.Description
		
		if ReceivedOption.PhraseKeys then
			for k, PhraseKey in pairs(ReceivedOption.PhraseKeys) do
				Description = string.Replace(Description, PhraseKey, Dictionary:GetPhrase(PhraseKey))
			end
		end

		if ReceivedOption.PhraseValues then
			for ValueToReplace, Value in pairs(ReceivedOption.PhraseValues) do
				Description = string.Replace(Description, "{" .. ValueToReplace .. "}", Value)
			end
		end

		table.insert(MenuOptions, {Name = Description, Order = ReceivedOption.Order, Function = function()
			hook.Remove("SetupMove", "ZPMenuKeyListener")
			hook.Remove("HUDPaint", "ChooseMenu")
			net.Start(MMenu.NetworkString)
				net.WriteString(ID)
			net.SendToServer()
		end})
	end
	
	table.sort(MenuOptions, function(a, b) return a.Order < b.Order end)
	MMenu:UpdateOptions(MenuOptions)
end)