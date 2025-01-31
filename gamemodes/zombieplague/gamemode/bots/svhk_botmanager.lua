hook.Add("ZPEndRound", "BotNewClassChoose", function()
    local BotPlayers = BotManager:GetBotPlayers()

    for K, Bot in pairs(BotPlayers) do
        if math.floor(math.random(1, 5)) == 1 then
            local NewClass = Bot:GetHumanBotBehavior():GetRandomPreferedClass()
            ClassManager:SetZPClass(Bot, NewClass, TEAM_HUMANS)
        end
        if math.floor(math.random(1, 5)) == 1 then
            local NewClass = Bot:GetZombieBotBehavior():GetRandomPreferedClass()
            ClassManager:SetZPClass(Bot, NewClass, TEAM_ZOMBIES)
        end
    end
end)

hook.Add("PostEntityTakeDamage", "BotDamageEvent", function(Target, DmgInfo, WasDamageTaken)
    if BotManager:IsBot(Target) then
        local Behavior = Target:IsZombie() and Target:GetZombieBotBehavior() or Target:GetHumanBotBehavior()

        if Target:Armor() > 0 && Target:Armor() < 10 then
            Behavior:CriticalArmorBehavior(Target)
        elseif Target:Health() < math.floor(Target:GetMaxHealth() / 10) then
            Behavior:CriticalHealthBehavior(Target)
            Target:SetNextCriticalHealthActionTime(CurTime() + math.floor(math.random(1, 5))) 
        end
    end
end)
hook.Add("ZPCureEvent", "BotCureEvent", function(Cured, Attacker, DmgInfo)
    for K, Ply in pairs(RoundManager:GetAliveHumans()) do
        local PathFinder = Ply:GetPathFinder()

        if PathFinder:GetEnemy() == Cured then
            BotManager:ResetPathFinder(Ply)
        end
    end

    BotManager:ResetPathFinder(Cured)
end)
hook.Add("ZPInfectionEvent", "BotInfectionEvent", function(Infected, Attacker, DmgInfo)
    for K, Ply in pairs(RoundManager:GetAliveZombies()) do
        local PathFinder = Ply:GetPathFinder()

        if PathFinder:GetEnemy() == Infected then
            BotManager:ResetPathFinder(Ply)
        end
    end

    BotManager:ResetPathFinder(Infected)
end)
hook.Add("PostPlayerDeath", "BotDeathEvent", function(DeadPlayer)
	for K, Ply in pairs(player.GetAll()) do
        local PathFinder = Ply:GetPathFinder()

        if PathFinder:GetEnemy() == DeadPlayer then
            BotManager:ResetPathFinder(Ply)
        end
    end

    BotManager:ResetPathFinder(DeadPlayer)
end)
hook.Add("SetupMove", "ZombiePlagueBotManagerSetupMove", function(Bot, Mv, Cmd)
    if Bot:IsBot() then
        BotManager:HandleStartCommand(Bot, Mv, Cmd)
    end
end)

hook.Add("StartCommand", "ZombiePlagueBotManagerStartCommand", function(Bot, Cmd)
    if Bot:IsBot() then
        BotManager:HandleBotInput(Bot, Cmd)
    end
end)
hook.Add("PostPlayerDeath", "ZombiePlagueBotManagerPlayerDeath", function(Ply)
    local PathFinder = Ply:GetPathFinder()

    if PathFinder then
        PathFinder:Remove()
    end
end)
hook.Add("PlayerDisconnected", "BotPlayerLeave", function(Ply)
    local PathFinder = Ply:GetPathFinder()

    if PathFinder then
        PathFinder:Remove()
    end
end)