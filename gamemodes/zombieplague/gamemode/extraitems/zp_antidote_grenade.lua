ExtraItem.ID = "ZPAntidoteGrenade"
ExtraItem.Name = "ExtraItemAntidoteGrenade"
ExtraItem.Price = 20
ExtraItem.BuySounds = { "items/medshot4.wav" }
function ExtraItem:OnBuy(ply)
    ply:Give('weapon_bugbait')
    local Weap = ply:GetWeapon('weapon_bugbait')
    hook.Add('OnEntityCreated', 'AntidoteGrenade'..ply:SteamID64(), function(ent)
        if ent:GetClass() == 'npc_grenade_bugbait' then
            util.SpriteTrail(ent, 0, Color(0,255,255), 1, 4, 8, 0.5, 1, 'trails/laser')
            timer.Simple(0, function()
                if IsValid(ent) then
                    if ent:GetOwner() == ply then
                        ply:StripWeapon('weapon_bugbait')
                        ent:CallOnRemove('AntidoteGrenadeOnExplosion'..ply:SteamID64(), function()
                            local explosion = ents.Create('env_explosion')
                            explosion:SetPos(ent:GetPos())
                            explosion:Spawn()
                            explosion:Fire('Explode')
                            explosion:Remove()
                            for k, v in ipairs(player.GetAll()) do
                                if !RoundManager:LastZombie() and ent:GetPos():DistToSqr(v:GetPos()) <= 20000 and ply ~= v and v:Team() == TEAM_ZOMBIES and !v:IsNemesis() then
                                    InfectionManager:Cure(v, ply)
                                    ply:GiveAmmoPacks(cvars.Number("zp_ap_cure_zombie", 3))
                                end
                            end
                        end)
                    end
                end
            end)
        end
    end)
    Weap:CallOnRemove('RemoveAntidoteGrenade'..ply:SteamID64(), function(ent)
        hook.Remove('OnEntityCreated', 'AntidoteGrenade'..ply:SteamID64())
    end)
end
function ExtraItem:CanBuy(ply)
    return !RoundManager:IsSpecialRound() && !RoundManager:LastZombie() && ply:Alive() && !ply:HasWeapon('weapon_bugbait')
end
Dictionary:RegisterPhrase("en-us", "ExtraItemAntidoteGrenade", "Antidote Grenade", false)
Dictionary:RegisterPhrase("ru", "ExtraItemAntidoteGrenade", "Антидотная граната", false)
Dictionary:RegisterPhrase("uk", "ExtraItemAntidoteGrenade", "Антидотна граната", false)