local BankStorageSource = {}
function BankStorageSource:Init()
    if !file.Exists("zombie_plague", "DATA") then
        file.CreateDir("zombie_plague")
    end
end
function BankStorageSource:GetPlayerAmmopacks(ply)
    return tonumber(file.Read("zombie_plague/" .. ply:SteamID64() .. ".txt", "DATA") or "0")
end
function BankStorageSource:Withdraw(ply, Amount)
    file.Write("zombie_plague/" .. ply:SteamID64() .. ".txt", BankStorageSource:GetPlayerAmmopacks(ply) - Amount)
end
function BankStorageSource:Deposit(ply, Amount)
    file.Write("zombie_plague/" .. ply:SteamID64() .. ".txt", BankStorageSource:GetPlayerAmmopacks(ply) + Amount)
end

Bank.BankStorageSource = BankStorageSource