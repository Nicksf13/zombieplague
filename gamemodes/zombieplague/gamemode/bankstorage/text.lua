local BankStorageSource = {}
function BankStorageSource:Init()
    if !file.Exists("zombie_plague", "DATA") then
        file.CreateDir("zombie_plague")
    end
end
function BankStorageSource:GetPlayerAmmopacks(ply)
    return tonumber(file.Read("zombie_plague/" .. ply:SteamID64() .. ".txt", "DATA") or "0")
end
BankStorageSource.Save = function(SteamID64, Amount)
    file.Write("zombie_plague/" .. SteamID64 .. ".txt", Amount)
end

Bank.BankStorageSource = BankStorageSource