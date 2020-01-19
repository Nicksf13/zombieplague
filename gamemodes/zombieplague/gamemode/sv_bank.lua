ConvarManager:CreateConVar("zp_auto_withdraw", 1, 8, "cvar used to set if server will auto withdraw player's ammo packs")
ConvarManager:CreateConVar("zp_auto_deposit_when_disconnect", 1, 8, "cvar used to set if server will auto withdraw player's ammo packs")

Bank = {BankStorageType = "text"}

include("zombieplague/gamemode/bankstorage/" .. Bank.BankStorageType .. ".lua")
Bank.BankStorageSource:Init()

if DEBUG_MODE then
	function Bank:Withdraw(ply, Amount)
		ply:GiveAmmoPacks(999999)
		return 999999, 999999
	end
	function Bank:Deposit(ply, Amount)
		ply:TakeAmmoPacks(0)
		return 999999, 999999
	end
else
	function Bank:Withdraw(ply, Amount)
		local PlyAmm = Bank.BankStorageSource:GetPlayerAmmopacks(ply)
		
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
				Bank.BankStorageSource:Withdraw(ply, Amount)
				
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
			ply:TakeAmmoPacks(Amount)
			Bank.BankStorageSource:Deposit(ply, Amount)
			
			return Amount, Bank.BankStorageSource:GetPlayerAmmopacks(ply)
		end
		return -1
	end
end

function Bank:GiveTakeAmmoPacks(Requester, Target, GiveTake, Amount)
	if Requester:IsSuperAdmin() then
		if Target then
			if Amount && Amount > 0 then
				if GiveTake then
					Target:GiveAmmoPacks(Amount)
					SendPopupMessage(Target, string.format(Dictionary:GetPhrase("AmmoPackGiveName", Target), Requester:Name(), Amount))
				else
					Target:TakeAmmoPacks(Amount)
					SendPopupMessage(Target, string.format(Dictionary:GetPhrase("AmmoPackTakeName", Target), Requester:Name(), Amount))
				end
			else
				SendPopupMessage(Requester, Dictionary:GetPhrase("AmmoPackGiveInvalidAmount", Requester))
			end
		else
			SendPopupMessage(Requester, Dictionary:GetPhrase("AmmoPackGivePlyNotFound", Requester))
		end
	else
		SendPopupMessage(Requester, Dictionary:GetPhrase("CommandNotAccess", Requester))
	end
end
hook.Add("PlayerAuthed", "ZPBankWithdraw", function(ply)
	if cvars.Bool("zp_auto_withdraw", 1) then
		Bank:Withdraw(ply, "*")
	end
end)
hook.Add("PlayerDisconnected", "ZPBankDeposit", function(ply)
	if cvars.Bool("zp_auto_deposit_when_disconnect", 1) then
		Bank:Deposit(ply, "*")
	end
end)
hook.Add("ShutDown", "ZPBankDepositAll", function()
	if cvars.Bool("zp_auto_deposit_when_disconnect", 1) then
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

Commands:AddCommand("balance", "Check your account balance.", function(ply)
	SendPopupMessage(ply, string.format(Dictionary:GetPhrase("AmmoPackBalance", ply), tonumber(file.Read("zombie_plague/" .. ply:SteamID64() .. ".txt", "DATA") or "0")))
end)

net.Receive("GiveTakeAmmoPack", function(len, ply)
	local Target
	local SteamID64 = net.ReadString()
	for k, v in pairs(player.GetAll()) do
		if string.find(v:SteamID64(), SteamID64) then
			Target = v
			break
		end
	end
	local GiveTake = net.ReadBool() and "give" or "take"
	local Amount = net.ReadInt(64)
	Bank:GiveTakeAmmoPacks(ply, Target, GiveTake, Amount)
end)

util.AddNetworkString("GiveTakeAmmoPack")