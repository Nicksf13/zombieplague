CreateConVar("zp_auto_withdraw", 1, 8, "cvar used to set if server will auto withdraw player's ammo packs")
CreateConVar("zp_auto_deposit", 1, 8, "cvar used to set if server will auto withdraw player's ammo packs")

Bank = {}

function Bank:Withdraw(ply, Amount)
	local PlyAmm = tonumber(file.Read("zombie_plague/" .. ply:SteamID64() .. ".txt", "DATA") or "0")
	
	if PlyAmm then
		if PlyAmm == 0 then
			return -2
		end
		if Amount == "*" then
			Amount = PlyAmm
		end
		Amount = tonumber(Amount)
		if Amount && PlyAmm >= Amount then
			ply:GiveAmmoPacks(Amount)
			file.Write("zombie_plague/" .. ply:SteamID64() .. ".txt", PlyAmm - Amount)
			
			return Amount, PlyAmm - Amount
		end
	end
	return -1
end
function Bank:Deposit(ply, Amount)
	if Amount == "*" then
		Amount = ply:GetAmmoPacks()
	end
	Amount = tonumber(Amount)
	if Amount && ply:GetAmmoPacks() >= Amount then
		if !file.Exists("zombie_plague", "DATA") then
			file.CreateDir("zombie_plague")
		end
		ply:TakeAmmoPacks(Amount)
		local PlyAmm = tonumber(file.Read("zombie_plague/" .. ply:SteamID64() .. ".txt", "DATA") or "0") + Amount
		file.Write("zombie_plague/" .. ply:SteamID64() .. ".txt", PlyAmm)
		
		return Amount, PlyAmm
	end
	return -1
end
hook.Add("PlayerAuthed", "ZPBankWithdraw", function(ply)
	if cvars.Bool("zp_auto_withdraw", 1) then
		Bank:Withdraw(ply, "*")
	end
end)
hook.Add("PlayerDisconnected", "ZPBankDeposit", function(ply)
	if cvars.Bool("zp_auto_deposit", 1) then
		Bank:Deposit(ply, "*")
	end
end)
hook.Add("ShutDown", "ZPBankDepositAll", function()
	if cvars.Bool("zp_auto_deposit", 1) then
		for k, ply in pairs(player.GetAll()) do
			Bank:Deposit(ply, "*")
		end
	end
end)
Commands:AddCommand("withdraw", "Withdraw specified amount from player's account.", function(ply, args)
	if (tonumber(args[1]) || args[1] == "*") && args[1] != "0" then
		local Amount, AccountAmount = Bank:Withdraw(ply, args[1])
		if Amount > 0 then
			SendPopupMessage(ply, string.format(Dictionary:GetPhrase("AmmoPackWithdraw", ply), Amount, AccountAmount))
		elseif Ammount == -1 then
			SendPopupMessage(ply, Dictionary:GetPhrase("AmmoPackNotEnought", ply))
		else
			SendPopupMessage(ply, Dictionary:GetPhrase("AmmoPackNoAmmoPacks", ply))
		end
	else
		SendPopupMessage(ply, Dictionary:GetPhrase("CommandInvalidArgument", ply))
	end
end, "<Amount>")
Commands:AddCommand("deposit", "Deposit specified amount from player's account.", function(ply, args)
	if (tonumber(args[1]) || args[1] == "*") && args[1] != "0" then
		local Amount, AccountAmount = Bank:Deposit(ply, args[1])
		if Amount > 0 then
			SendPopupMessage(ply, string.format(Dictionary:GetPhrase("AmmoPackDeposit", ply), Amount, AccountAmount))
		else
			SendPopupMessage(ply, Dictionary:GetPhrase("AmmoPackNotEnought", ply))
		end
	else
		SendPopupMessage(ply, Dictionary:GetPhrase("CommandInvalidArgument", ply))
	end
end, "<Amount>")
Commands:AddCommand("give", "Donate your ammo packs to another player.", function(ply, args)
	local Amount = tonumber(args[2])
	if (Amount || args[2] == "*") && args[2] != "0" then
		if args[2] == "*" then
			Amount = ply:GetAmmoPacks()
		end
		if ply:GetAmmoPacks() > Amount then
			local Winner
			for k, v in pairs(player.GetAll()) do
				if string.find(string.lower(v:Name()), args[1]) then
					Winner = v
					break
				end
			end
			if Winner then
				ply:TakeAmmoPacks(Amount)
				Winner:GiveAmmoPacks(Amount)
				SendPopupMessage(Winner, string.format(Dictionary:GetPhrase("AmmoPackGiveName", Winner), ply:Name(), Amount))
				SendPopupMessage(ply, string.format(Dictionary:GetPhrase("AmmoPackGiverMessage", ply), Amount, Winner:Name()))
			else
				SendPopupMessage(ply, Dictionary:GetPhrase("AmmoPackPlayerNotFound", ply))
			end
		else
			SendPopupMessage(ply, Dictionary:GetPhrase("AmmoPackNotEnought", ply))
		end
	else
		SendPopupMessage(ply, Dictionary:GetPhrase("CommandInvalidArgument", ply))
	end
end, "<Player> <Amount>")
Commands:AddCommand({"balance", "saldo"}, "Check your account balance.", function(ply)
	SendPopupMessage(ply, string.format(Dictionary:GetPhrase("AmmoPackBalance", ply), tonumber(file.Read("zombie_plague/" .. ply:SteamID64() .. ".txt", "DATA") or "0")))
end)
Commands:AddCommand("ammopacks", "Give ammo packs to the specified player.", function(ply, args)
	if ply:IsSuperAdmin() then
		local Amount = tonumber(args[3] or "")
		if Amount then
			local aux
			for k, v in pairs(player.GetAll()) do
				if string.find(string.lower(v:Name()), args[2]) then
					aux = v
					break
				end
			end
			if aux then
				if args[1] == "give" then
					aux:GiveAmmoPacks(Amount)
					SendPopupMessage(aux, string.format(Dictionary:GetPhrase("AmmoPackGiveName", aux), ply:Name(), Amount))
				elseif args[1] == "take" then
					aux:TakeAmmoPacks(Amount)
					SendPopupMessage(aux, string.format(Dictionary:GetPhrase("AmmoPackTakeName", aux), ply:Name(), Amount))
				else
					SendPopupMessage(ply, Dictionary:GetPhrase("CommandInvalidArgument", ply))
				end
			else
				SendPopupMessage(ply, Dictionary:GetPhrase("AmmoPackGivePlyNotFound", ply))
			end
		else
			SendPopupMessage(ply, Dictionary:GetPhrase("AmmoPackGiveInvalidAmount", ply))
		end
	else
		SendPopupMessage(ply, Dictionary:GetPhrase("CommandNotAccess", ply))
	end
end, "<Player>", true)