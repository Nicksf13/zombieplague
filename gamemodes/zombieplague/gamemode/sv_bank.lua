Bank = {BankStorageType = "text", AmmoPacksStorage = {}, Time = 5, ShouldSaveAmmoPacks = true}

function Bank:SetPlayerAmmoPacks(ply, Amount)
	Bank.AmmoPacksStorage[ply:SteamID64()] = Amount
end
function Bank:Save()
	for SteamID64, Amount in pairs(Bank.AmmoPacksStorage) do
		local Success, Error = pcall(Bank.BankStorageSource.Save, SteamID64, Amount)
		if Success then
			Bank.AmmoPacksStorage[SteamID64] = nil
		elseif Error then
			print("Error on ammo pack saving:")
			print(Error)
		end
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

if Bank.ShouldSaveAmmoPacks then
	include("zombieplague/gamemode/bankstorage/" .. Bank.BankStorageType .. ".lua")
	Bank.BankStorageSource:Init()

	hook.Add("PlayerAuthed", "ZPBankWithdraw", function(ply)
		ply:SetAmmoPacks(Bank.BankStorageSource:GetPlayerAmmopacks(ply), true)
	end)
	hook.Add("ShutDown", "ZPBankDepositAll", Bank.Save)
	
	timer.Create("ZPBankSaver", Bank.Time, 0, Bank.Save)
end