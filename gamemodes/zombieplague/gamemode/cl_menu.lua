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
		MMenu.ZPOptions.FixedOptions = {}
		MMenu.ZPOptions.BiggestTextSize = 0
	end

	function MMenu:UpdateOptions(Options, FixedOptions)
		if table.Count(Options) > 0 then
			MMenu.Options = Options
			MMenu.FixedOptions = FixedOptions
			
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
		
		local TotalOptionsAvailable = 7 - table.Count(MMenu.FixedOptions or {})

		local PgJump = TotalOptionsAvailable * (MMenu.Page - 1)
		local i = 1
		while(i < (TotalOptionsAvailable + 1) && MMenu.Options[PgJump + i]) do
			MMenu.ZPOptions:AddLine(i .. " - " .. MMenu.Options[PgJump + i].Name, MMenu.Options[PgJump + i].Function, NumpadKeys[i])
			i = i + 1
		end

		i = 1
		for k, FixedOption in pairs(MMenu.FixedOptions) do
			local Key = 8 - i
			local PressFunction = function()
				MMenu:GetPressFunction(FixedOption)()
				
				MMenu:SetPage(Page)
			end
			MMenu.ZPOptions:AddLine(Key .. " - " .. MMenu:GetFormatedText(FixedOption), PressFunction, NumpadKeys[Key])

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
	function MMenu:GetFormatedText(FixedOption)
		if FixedOption.Type == "Boolean" then
			return FixedOption.DescribeText .. " " .. (FixedOption.Value and Dictionary:GetPhrase("PopupYes") or Dictionary:GetPhrase("PopupNo"))
		end

		return string.format(FixedOption.DescribeText, FixedOption.Value)
	end
	function MMenu:GetPressFunction(FixedOption)
		if FixedOption.Type == "Boolean" then
			return function()
				FixedOption.Value = !FixedOption.Value
			end
		end

		return function()
			local NewValue = FixedOption.Value + FixedOption.IncrementValue

			if NewValue > FixedOption.MaxValue then
				NewValue = FixedOption.MinValue
			elseif NewValue < FixedOption.MinValue then
				NewValue = FixedOption.MaxValue
			end

			FixedOption.Value = NewValue
		end
	end
end
function OpenWeaponMenu()
	local Options = {}
	table.insert(Options, {Order = 1, Name = Dictionary:GetPhrase("MenuPrimaryWeaponChoose"), Function = function() net.Start("RequestPrimaryWeaponMenu") net.SendToServer() hook.Remove("SetupMove", "ZPMenuKeyListener") hook.Remove("HUDPaint", "ChooseMenu") end})
	table.insert(Options, {Order = 2, Name = Dictionary:GetPhrase("MenuSecondaryWeaponChoose"), Function = function() net.Start("RequestSecondaryWeaponMenu") net.SendToServer() hook.Remove("SetupMove", "ZPMenuKeyListener") hook.Remove("HUDPaint", "ChooseMenu") end})
	table.insert(Options, {Order = 3, Name = Dictionary:GetPhrase("MenuMeleeWeaponChoose"), Function = function() net.Start("RequestMeleeWeaponMenu") net.SendToServer() hook.Remove("SetupMove", "ZPMenuKeyListener") hook.Remove("HUDPaint", "ChooseMenu") end})

	MMenu:UpdateOptions(Options, {})
end
function OpenZPMenu()
	local Options = {}
	table.insert(Options, {Order = 1, Name = Dictionary:GetPhrase("MenuZombieChoose"), Function = function() net.Start("RequestZombieMenu") net.SendToServer() hook.Remove("SetupMove", "ZPMenuKeyListener") hook.Remove("HUDPaint", "ChooseMenu") end})
	table.insert(Options, {Order = 2, Name = Dictionary:GetPhrase("MenuHumanChoose"), Function = function() net.Start("RequestHumanMenu") net.SendToServer() hook.Remove("SetupMove", "ZPMenuKeyListener") hook.Remove("HUDPaint", "ChooseMenu") end})
	table.insert(Options, {Order = 3, Name = Dictionary:GetPhrase("MenuWeaponChoose"), Function = OpenWeaponMenu})
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

				MMenu:UpdateOptions(AdminOptions, {})
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
	
	MMenu:UpdateOptions(Options, {})
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
	local HasFixedOptions = net.ReadBool()
	local FixedOptions = {}
	if HasFixedOptions then
		FixedOptions = net.ReadTable()
	end
	
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
				net.WriteBool(HasFixedOptions)
				if HasFixedOptions then
					local SendFixedOptions = {}
					for k, FixedOption in pairs(FixedOptions) do
						SendFixedOptions[k] = {Value = FixedOption.Value}
					end
					
					net.WriteTable(SendFixedOptions)
				end
			net.SendToServer()
		end})
	end
	
	table.sort(MenuOptions, function(a, b) return a.Order < b.Order end)
	MMenu:UpdateOptions(MenuOptions, FixedOptions)
end)