local BankStorageSource = {}
function BankStorageSource:Init()
    if !file.Exists("zombieplague", "DATA") then
        file.CreateDir("zombieplague")
    end
    if !file.Exists("zombieplague/bank", "DATA") then
        file.CreateDir("zombieplague/bank")
    end

    --Migrates old folder structure files
    if file.Exists("zombie_plague", "DATA") then
        local Files, Directories = file.Find("zombie_plague/*.txt", "DATA")

        for k, File in pairs(Files) do
            local AmmoPacks = file.Read("zombie_plague/" .. File, "DATA")
            file.Write("zombieplague/bank/" .. File, AmmoPacks)

            file.Delete("zombie_plague/" .. File, "DATA")
        end

        file.Delete("zombie_plague", "DATA")
    end
end
function BankStorageSource:GetPlayerAmmopacks(ply)
    return tonumber(file.Read("zombieplague/bank/" .. ply:SteamID64() .. ".txt", "DATA") or "0")
end
BankStorageSource.Save = function(SteamID64, Amount)
    file.Write("zombieplague/bank/" .. SteamID64 .. ".txt", Amount)
end

Bank.BankStorageSource = BankStorageSource