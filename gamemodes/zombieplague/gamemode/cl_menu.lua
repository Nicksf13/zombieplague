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
	
	function MMenu.ZPOptions:AddLine(Text)
		table.insert(MMenu.ZPOptions.Options, Text)
	end
	function MMenu.ZPOptions:Clear()
		MMenu.ZPOptions.Options = {}
	end

	function MMenu:UpdateOptions(Options)
		MMenu.Options = Options
		
		MMenu:SetPage(1)
		
		hook.Add("SetupMove", "ZPMenuKeyListener", function(ply, mvd)
			for k, PressFunction in pairs(MMenu.ZPOptions.PressFunctions) do
				if input.WasKeyPressed(NumpadKeys[k]) && MMenu.LastPress < CurTime() then
					PressFunction(7 * (MMenu.Page - 1) + k)
					MMenu.LastPress = CurTime() + 0.1
					break
				end
			end
		end)
	end

	function MMenu:SetPage(Page)
		hook.Remove("HUDPaint", "ChooseMenu")
		MMenu.Page = Page
		MMenu.ZPOptions.PressFunctions = {}
		MMenu.ZPOptions:Clear()
		
		local PgJump = 7 * (MMenu.Page - 1)
		local i = 1
		while(i < 8 && MMenu.Options[PgJump + i]) do
			MMenu.ZPOptions:AddLine(i .. " - " .. MMenu.Options[PgJump + i].Name)
			MMenu.ZPOptions.PressFunctions[i] = MMenu.Options[PgJump + i].Function
			i = i + 1
		end
		
		if MMenu.Page > 1 then
			MMenu.ZPOptions.Options[8] = "8 - " .. Dictionary:GetPhrase("MenuBack")
			MMenu.ZPOptions.PressFunctions[8] = function()
				MMenu:SetPage(MMenu.Page - 1)
			end
		end
		
		if MMenu.Page < table.Count(MMenu.Options) / 7 then
			MMenu.ZPOptions.Options[9] = "9 - " .. Dictionary:GetPhrase("MenuNext")
			MMenu.ZPOptions.PressFunctions[9] = function()
				MMenu:SetPage(MMenu.Page + 1)
			end
		end
		
		MMenu.ZPOptions.Options[10] = "0 - " .. Dictionary:GetPhrase("MenuClose")
		MMenu.ZPOptions.PressFunctions[10] = function()
			MMenu.ZPOptions.PressFunctions = {}
			MMenu.ZPOptions:Clear()
			hook.Remove("SetupMove", "ZPMenuKeyListener")
			hook.Remove("HUDPaint", "ChooseMenu")
		end
		hook.Add("HUDPaint", "ChooseMenu", function()
			local i = 1
			local Allign = (ScrH() / 2) - ((table.Count(MMenu.ZPOptions.Options)*20)/2)
			for k, Text in pairs(MMenu.ZPOptions.Options) do
				draw.DrawText(Text, "DermaDefault", 20, (i * 20) + Allign, Color(255, 255, 255, 255), TEXT_ALIGN_LEFT)
				i = i + 1
			end
		end)
	end
end
function OpenZPMenu()
	local Options = {}
	table.insert(Options, {Name = Dictionary:GetPhrase("MenuZombieChoose"), Function = function() net.Start("RequestZombieMenu") net.SendToServer() hook.Remove("SetupMove", "ZPMenuKeyListener") hook.Remove("HUDPaint", "ChooseMenu") end})
	table.insert(Options, {Name = Dictionary:GetPhrase("MenuHumanChoose"), Function = function() net.Start("RequestHumanMenu") net.SendToServer() hook.Remove("SetupMove", "ZPMenuKeyListener") hook.Remove("HUDPaint", "ChooseMenu") end})
	table.insert(Options, {Name = Dictionary:GetPhrase("MenuWeaponChoose"), Function = function() net.Start("RequestWeaponMenu") net.SendToServer() hook.Remove("SetupMove", "ZPMenuKeyListener") hook.Remove("HUDPaint", "ChooseMenu") end})
	table.insert(Options, {Name = Dictionary:GetPhrase("MenuExtraItemChoose"), Function = function() net.Start("RequestExtraItemMenu") net.SendToServer() hook.Remove("SetupMove", "ZPMenuKeyListener") hook.Remove("HUDPaint", "ChooseMenu") end})
	table.insert(Options, {Name = Dictionary:GetPhrase("MenuLanguageChoose"), Function = function() net.Start("RequestLanguageMenu") net.SendToServer() hook.Remove("SetupMove", "ZPMenuKeyListener") hook.Remove("HUDPaint", "ChooseMenu") end})
	Options[7] = {Name = (LocalPlayer():Team() != TEAM_SPECTATOR and Dictionary:GetPhrase("MenuSpectator") or Dictionary:GetPhrase("MenuNonSpectator")), Function = function() net.Start("RequestSpectator") net.SendToServer() hook.Remove("SetupMove", "ZPMenuKeyListener") hook.Remove("HUDPaint", "ChooseMenu")end}
	if LocalPlayer():IsAdmin() || LocalPlayer():IsSuperAdmin() then
		table.insert(Options, {
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

				if(table.Count(AdminOptions) > 0) then
					MMenu:UpdateOptions(AdminOptions)
				else
					notification.AddLegacy(Dictionary:GetPhrase("MenuNoOptionsAvailableNow"), NOTIFY_GENERIC, 5)
				end
			end
		})
	end
	table.insert(Options, {
		Name = Dictionary:GetPhrase("MenuCredit"),
		Function = function()
			local CreditsOptions = {}
			table.insert(CreditsOptions, GenerateMenuOption(
				Dictionary:GetPhrase("MenuCreditMeRcyLeZZ"),
				function()
					gui.OpenURL("https://forums.alliedmods.net/member.php?u=33273")
				end,
				0
			))
			table.insert(CreditsOptions, GenerateMenuOption(
				Dictionary:GetPhrase("MenuCreditZombiePlague"),
				function()
					gui.OpenURL("https://forums.alliedmods.net/showthread.php?t=72505")
				end,
				1
			))
			table.insert(CreditsOptions, GenerateMenuOption(
				Dictionary:GetPhrase("MenuCreditTheFireFuchs"),
				function()
					gui.OpenURL("https://steamcommunity.com/id/thefirefuchs")
				end,
				2
			))
			table.insert(CreditsOptions, GenerateMenuOption(
				Dictionary:GetPhrase("MenuCreditErickMaksimets"),
				function()
					gui.OpenURL("https://github.com/ErickMaksimets")
				end,
				3
			))
			table.insert(CreditsOptions, GenerateMenuOption(
				Dictionary:GetPhrase("MenuCreditBlueberryy"),
				function()
					gui.OpenURL("https://github.com/Blueberryy")
				end,
				4
			))
			MMenu:UpdateOptions(CreditsOptions)
		end,
		Order = 1000
	})
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
	for k, Option in pairs(ReceivedOptions) do
		if Option.Translations then
		end
	end
	local MenuOptions = {}

	for ID, ReceivedOption in pairs(ReceivedOptions) do
		local Description = ReceivedOption.Phrase and Dictionary:GetPhrase(ReceivedOption.Phrase) or ReceivedOption.Description

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