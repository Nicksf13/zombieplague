BotManager = {}
HumanBotBehavior = {}
ZombieBotBehavior = {}

BotManager.HidingSpotsToUse = {}
BotManager.RandomHidingSpotsList = {}
BotManager.HumanBehaviors = {}
BotManager.ZombieBehaviors = {}
BotManager.NameList = {
    "Eric",
    "Fire",
    "John",
    "Lola",
    "Get_Wrong",
    "Raised",
    "U R 2 Slow",
    "Alakazan",
    "Arrows",
    "HotZera",
    "Lerooy",
    "Jenkins",
    "MrWild",
    "2 late 2 sea"
}

function BotManager:Initialize()
    table.insert(BotManager.HumanBehaviors, HumanBotBehavior)
    table.insert(BotManager.ZombieBehaviors, ZombieBotBehavior)
end
function BotManager:CreateIntelligentBot(Name)
    local RandomName = Name
    if !RandomName then
        RandomName = SafeTableRandom(BotManager.NameList)
    end

    local NewBotPlayer = player.CreateNextBot(RandomName)
    local HumanBotBehavior, Key = table.Random(self.HumanBehaviors)
    local ZombieBotBehavior, Key = table.Random(self.ZombieBehaviors)

    NewBotPlayer:SetHumanBotBehavior(HumanBotBehavior)
    NewBotPlayer:SetZombieBotBehavior(ZombieBotBehavior)

    return NewBotPlayer
end
function BotManager:GetBavior(Bot)
    if Bot:Team() == TEAM_HUMANS then
        return Bot:GetHumanBotBehavior()
    end

    return Bot:GetZombieBotBehavior()
end
function BotManager:HandleBotInput(Bot, Cmd)
    local PathFinder = Bot:GetPathFinder()

    Cmd:ClearButtons()
    Cmd:ClearMovement()
    Cmd:SetButtons(PathFinder:GetKeys())
end
function BotManager:HandleStartCommand(Bot, Mv, Cmd)
    local Keys = IN_FORWARD

    local PathFinder = Bot:GetPathFinder()
    local Behavior = BotManager:GetBavior(Bot)
    local ZPClass = Bot:GetZPClass()

    Behavior:ForgetEnemyBehavior(Bot)
    Behavior:SearchForEnemyBehavior(Bot)
    Behavior:MovementBehavior(Bot)

    local StuckPlace = {
        InitialTime = CurTime(),
        Pos = Bot:GetPos()
    }

    PathFinder:SetStuckPlace(StuckPlace)

    local BotViewAngle = Bot:EyeAngles()
    local ShootPosition = Bot:GetShootPos()
    local NextPos
    local ViewAngle
    if PathFinder:HasNextSegment() then
        local NextSegment = PathFinder:GetNextSegment()
        local CurrentSegment = PathFinder:GetCurrentSegment()
        NextSegment.area:Draw()
        NextPos = NextSegment.pos

        if Vector(Bot:GetPos().x, Bot:GetPos().y, 0):DistToSqr(Vector(NextPos.x, NextPos.y)) < 100 then
            PathFinder:SkipSegment()
        end

        Keys = BotManager:HandleWalkAction(Bot, CurrentSegment, Mv, Keys)

        ViewAngle = LerpAngle(0.1, Bot:EyeAngles(), (NextSegment.area:GetCenter() - Bot:GetShootPos()):Angle())
        ViewAngle.pitch = 0

        if CurrentSegment.area:HasAttributes(NAV_MESH_JUMP) || NextSegment.type >= 2 then
            -- Jump over a gap
            if NextSegment.type == 3 then
                -- Put logic to jump over a gap here
            end
            Keys = BotManager:MakeJumpCrouchAction(Bot, Keys)
        elseif CurrentSegment.area:HasAttributes(NAV_MESH_CROUCH) then
            Keys = Keys + IN_DUCK
        end
    elseif PathFinder:GetTargetPos() then
        ViewAngle = LerpAngle(0.1, Bot:EyeAngles(), (PathFinder:GetTargetPos() - Bot:GetShootPos()):Angle())
        NextPos = PathFinder:GetTargetPos()

        -- Just run
        Mv:SetForwardSpeed(Bot:GetRunSpeed())
        Keys = Keys + IN_RUN
    end

    if PathFinder:GetTargetPos() then
        Keys = BotManager:HandleStuck(Bot, NextPos, Mv, Keys)
    end

    local Enemy = PathFinder:GetEnemy()
    if Enemy then
        ViewAngle = LerpAngle(1, Bot:EyeAngles(), (Enemy:GetPos() - Bot:GetShootPos()):Angle())
        Keys = Behavior:AttackBehavior(Bot, Enemy, Keys)
    end

    if NextPos then
        local MovimentAngle = ((NextPos + Bot:GetCurrentViewOffset()) - ShootPosition):Angle()
        Mv:SetMoveAngles(MovimentAngle)

        Keys = BotManager:HandleLadderMovement(Bot, NextPos, ViewAngle, Keys)
    end

    if !ViewAngle then
        ViewAngle = Bot:EyeAngles()
    end

    Bot:SetEyeAngles(ViewAngle)

    --Breaks breakable entities, very useful for getting a path
    local TraceResult = util.QuickTrace(Bot:EyePos(), Bot:GetForward() * 30, Bot)
    if (IsValid(TraceResult.Entity) and TraceResult.Entity:GetClass() == "func_breakable") then
        Keys = Keys + IN_ATTACK
    end

    PathFinder:SetKeys(Keys)
end
function BotManager:HandleWalkAction(Bot, CurrentSegment, Mv, Keys)
    if CurrentSegment.area:HasAttributes(NAV_MESH_WALK) then
        Mv:SetForwardSpeed(Bot:GetSlowWalkSpeed())
        Keys = Keys + IN_WALK
    elseif !cvars.Bool("zp_run_drain", false) || CurrentSegment.area:HasAttributes(NAV_MESH_RUN) then
        -- Implement logic for handling run drain
        Mv:SetForwardSpeed(Bot:GetRunSpeed())
        Keys = Keys + IN_RUN
    else
        Mv:SetForwardSpeed(Bot:GetWalkSpeed())
    end

    return Keys
end
function BotManager:MakeJumpCrouchAction(Bot, Keys)
    local PathFinder = Bot:GetPathFinder()
    if PathFinder:ShouldJump() then
        Keys = Keys + IN_JUMP
        PathFinder:SetNextJump(CurTime() + 1)
    end

    --Only crouches when in the air, for avoiding getting stuck
    if PathFinder:ShouldCrouch() && !Bot:IsOnGround() then
        Keys = Keys + IN_DUCK
        PathFinder:SetNextCrouch(CurTime() + 0.1)
    end

    return Keys
end
function BotManager:HandleLadderMovement(Bot, NextPos, ViewAngle, Keys)
    if Bot:GetMoveType() == MOVETYPE_LADDER then
        if Bot:GetPos().z > NextPos.z then
            ViewAngle.pitch = -20
        elseif Bot:GetPos().z > NextPos.z then
            ViewAngle.pitch = 20
        elseif Bot.NextJumpOnLadder && Bot.NextJumpOnLadder < CurTime() then
            Keys = Keys + IN_JUMP
        end

        if !Bot.NextJumpOnLadder then
            Bot.NextJumpOnLadder = CurTime() + 2
        end
    else
        Bot.NextJumpOnLadder = nil
    end

    return Keys
end
function BotManager:HandleStuck(Bot, NextPos, Mv, Keys)
    local PathFinder = Bot:GetPathFinder()
    if PathFinder:IsStuckInSamePlace() then
        local Direction = BotManager:CalculateSideDirection(Bot, NextPos)

        if Direction > 0 then
            Mv:SetSideSpeed(-2500)
            Keys = Keys + IN_MOVELEFT
        elseif Direction < 0 then
            Mv:SetSideSpeed(2500)
            Keys = Keys + IN_MOVERIGHT
        end
    end

    return Keys
end
function BotManager:CalculateSideDirection(Bot, TargetPos)
    local PlayerPos = Bot:GetPos()
    local EnemyPos = TargetPos

    local PlayerForward = Bot:EyeAngles():Forward()
    local PlayerRight = PlayerForward:Angle():Right()

    local EnemyDirection = (EnemyPos - PlayerPos):GetNormalized()
    local DotProduct = PlayerRight:Dot(EnemyDirection)

    return DotProduct
end
function BotManager:FindRandomHidingSpot()
    local HidingSpots = BotManager:GetHidingSpots()
    local RandomHidingSpotsList = self.RandomHidingSpotsList

    if #RandomHidingSpotsList < 1 then
        for k, v in pairs(HidingSpots) do
            table.insert(RandomHidingSpotsList, v)
        end
    end

    if #RandomHidingSpotsList < 1 then
        return nil
    end

    local Value, Key = table.Random(RandomHidingSpotsList)
    RandomHidingSpotsList[Key] = nil

    return Value
end
function BotManager:GetHidingSpots()
    if #BotManager.HidingSpotsToUse < 1 then
        BotManager:FindHidingSpots()
    end

    return BotManager.HidingSpotsToUse
end
function BotManager:FindHidingSpots()
    local Areas = navmesh.GetAllNavAreas()

    for K, Area in pairs(Areas) do
        local HidingSpots = Area:GetHidingSpots()

        
        for J, HidingSpot in pairs(HidingSpots) do
            table.insert(BotManager.HidingSpotsToUse, HidingSpot)
        end
    end
end
function BotManager:GetNearstEnemy(Bot, DistanceFilter)
    DistanceFilter = DistanceFilter and DistanceFilter or 100000000

    local PlayerTable = RoundManager:GetAliveHumans()

    if Bot:IsHuman() then
        PlayerTable = RoundManager:GetAliveZombies()
    end

    local DistanceToNextTarget = DistanceFilter
    local Target
    for Key, PlayerTarget in pairs(PlayerTable) do
        if BotManager:CanSee(Bot, PlayerTarget) then
            local DistanceToTarget = Bot:GetPos():Distance(PlayerTarget:GetPos())
            if DistanceToTarget < DistanceFilter && DistanceToTarget < DistanceToNextTarget then
                Target = PlayerTarget
                DistanceToNextTarget = DistanceToTarget
            end
        end
    end

    return Target
end
function BotManager:CanSee(Bot, Ent)
    return Bot:Visible(Ent)
end
function BotManager:IsBotTargetToEnemyBot(Bot, EnemyBot)
    local PathFinder = EnemyBot:GetPathFinder()
    if !PathFinder:GetEnemy() then
        return false
    end

    return Bot == PathFinder:GetEnemy()
end
function BotManager:ComputeDistance(Bot, Position)
    local DistanceCalculator = Bot:GetDistanceCalculator()
    local Path = DistanceCalculator:GetPath()
    local Length = DistanceCalculator:ComputePath(Path, Position)
    Path:Draw()

    return Length
end
function BotManager:IsBot(Ply)
    return Ply:IsBot()
end
-- In the future we might have afk players, so this is the reason instead of calling player.GetBots
function BotManager:GetBotPlayers()
    local BotPlayers = {}
    for K, Bot in pairs(player.GetAll()) do
        if BotManager:IsBot(Bot) then
            table.insert(BotPlayers, Bot)
        end
    end

    return BotPlayers
end
function BotManager:IsBot(Player)
    return Player:IsBot() and true or false
end
function BotManager:ResetPathFinder(Player)
    local PathFinder = Player:GetPathFinder()

    PathFinder:SetTargetPos(nil)
    PathFinder:SetEnemy(nil)
    PathFinder:SetTargetPos(nil)
    PathFinder:SetForgetEnemyTime(nil)
end

HumanBotBehavior.__index = HumanBotBehavior
HumanBotBehavior.PreferedClasses = {
    "CrouchHuman",
    "LightHuman",
    "SuicidalHuman"
}

function HumanBotBehavior:MovementBehavior(Bot)
    local PathFinder = Bot:GetPathFinder()
    if !PathFinder:GetTargetPos() && !PathFinder:IsInTargetPos() then
        local RandomHidingSpot = BotManager:FindRandomHidingSpot()

        PathFinder:SetTargetPos(RandomHidingSpot)
    end
end
function HumanBotBehavior:SearchForEnemyBehavior(Bot)
    local PathFinder = Bot:GetPathFinder()

    local NearstEnemy
    -- If the bot is safe, he will search for targets to fight
    if PathFinder:IsInTargetPos() then
        NearstEnemy = BotManager:GetNearstEnemy(Bot, 100000)
    else
        NearstEnemy = self:GetNearstEnemy(Bot, 600, 600)
    end

    PathFinder:SetEnemy(NearstEnemy)

    if NearstEnemy then
        local EnemyDistance = BotManager:ComputeDistance(NearstEnemy, Bot:GetPos())
        if EnemyDistance < 400 then
            self:CloseToEnemyBehavior(Bot, NearstEnemy)
        end
    end
end
function HumanBotBehavior:ForgetEnemyBehavior(Bot)
    local PathFinder = Bot:GetPathFinder()
    local Enemy = PathFinder:GetEnemy()

    if Enemy && !Bot:Visible(Enemy) then
        PathFinder:SetEnemy(nil)
    end
end
function HumanBotBehavior:AttackBehavior(Bot, Enemy, Keys)
    return Keys + IN_ATTACK
end
function HumanBotBehavior:TakeDamageBehavior(Bot, Attacker)
    local PathFinder = Bot:GetPathFinder()

    PathFinder:SetEnemy(Attacker)
end
function HumanBotBehavior:GetRandomPreferedClass()
    local _, Class = table.Random(HumanBotBehavior.PreferedClasses)

    return class
end
function HumanBotBehavior:CriticalHealthBehavior(Bot)
    if Bot:Team() == TEAM_HUMANS then
        local ArmorExtraItem = ExtraItemsManager:GetItemById(Bot:Team(), "ZPArmor")

        if Bot:GetAmmoPacks() >= ArmorExtraItem.Price then
            ExtraItemsManager:BuyItem(Bot, ArmorExtraItem)
        end
    end
end
function HumanBotBehavior:CriticalArmorBehavior(Bot)
    if Bot:Team() == TEAM_HUMANS then
        local ArmorExtraItem = ExtraItemsManager:GetItemById(Bot:Team(), "ZPArmor")

        if Bot:GetAmmoPacks() >= ArmorExtraItem.Price then
            ExtraItemsManager:BuyItem(Bot, ArmorExtraItem)
        end
    end
end
function HumanBotBehavior:GetNearstEnemy(Bot, DistanceFilter, PathLengthFilter)
    local NearstEnemy = BotManager:GetNearstEnemy(Bot, DistanceFilter)

    if !NearstEnemy then
        return nil
    end

    local Distance = BotManager:ComputeDistance(NearstEnemy, Bot:GetPos())

    if Distance > PathLengthFilter then
        return nil
    end

    if !NearstEnemy:IsBot() then
        return NearstEnemy
    end

    return BotManager:IsBotTargetToEnemyBot(Bot, NearstEnemy) and NearstEnemy or nil
end
function HumanBotBehavior:CloseToEnemyBehavior(Bot, Enemy)
    local PathFinder = Bot:GetPathFinder()

    local Area = navmesh.GetNearestNavArea(Bot:GetPos())
    local EnemyArea = navmesh.GetNearestNavArea(Enemy:GetPos())
    local ListOfAdjacentAreas = Area:GetAdjacentAreas()
    local FarestDistance = 0
    local FarestArea
    for Key, Value in pairs(ListOfAdjacentAreas) do
        local AreaAndPlayerDistance = BotManager:ComputeDistance(Bot, Value:GetCenter())
        local AreaAndEnemyDistance = BotManager:ComputeDistance(Enemy, Value:GetCenter())
        if AreaAndEnemyDistance > AreaAndPlayerDistance && AreaAndEnemyDistance > FarestDistance then
            FarestDistance = AreaAndEnemyDistance
            FarestArea = Value
        end
    end

    if FarestArea then
        FarestArea:Draw()
    end
    local Destination = FarestArea and FarestArea:GetCenter() or Area:GetCenter()

    PathFinder:SetTargetPos(Destination)
end

HumanBotBehavior.__index = HumanBotBehavior
HumanBotBehavior.PreferedClasses = {
    "CrouchHuman",
    "LightHuman",
    "SuicidalHuman"
}

ZombieBotBehavior.__index = ZombieBotBehavior
ZombieBotBehavior.PreferedClasses = {
    "ZombieJumperClassName",
    "ZombieLightClassName",
    "ZombieSpeedClassName",
    "ZombieLeechClassName"
}

function ZombieBotBehavior:MovementBehavior(Bot)
    local PathFinder = Bot:GetPathFinder()
    local CurrentEnemy = PathFinder:GetEnemy()

    if CurrentEnemy then
        PathFinder:SetTargetPos(CurrentEnemy:GetPos())
    elseif !PathFinder:GetTargetPos() then
        local RandomHidingSpot = BotManager:FindRandomHidingSpot()

        PathFinder:SetTargetPos(RandomHidingSpot)
    end
end
function ZombieBotBehavior:SearchForEnemyBehavior(Bot)
    local PathFinder = Bot:GetPathFinder()
    local CurrentEnemy = PathFinder:GetEnemy()

    if !CurrentEnemy then
        local NearstEnemy = BotManager:GetNearstEnemy(Bot, 100000)
    
        if NearstEnemy then
            PathFinder:SetForgetEnemyTime(CurTime() + 15)

            PathFinder:SetEnemy(NearstEnemy)
        end
    elseif Bot:Visible(CurrentEnemy) then
        PathFinder:SetForgetEnemyTime(CurTime() + 15)
    end
end
function ZombieBotBehavior:ForgetEnemyBehavior(Bot)
    local PathFinder = Bot:GetPathFinder()

    if PathFinder:GetForgetEnemyTime() && PathFinder:GetForgetEnemyTime() < CurTime() then
        BotManager:ResetPathFinder(Bot)
    end
end
function ZombieBotBehavior:AttackBehavior(Bot, Enemy, Keys)
    local PathFinder = Bot:GetPathFinder()
    local Distance = Bot:GetPos():Distance(Enemy:GetPos())

    if Distance < 100 then
        Keys = Keys + IN_ATTACK
    end

    return Keys
end
function ZombieBotBehavior:TakeDamageBehavior(Bot, Attacker)
    local PathFinder = Bot:GetPathFinder()

    if !PathFinder:GetEnemy() then
        PathFinder:SetEnemy(Attacker)
        PathFinder:SetForgetEnemyTime(CurTime() + 30)
    end
end
function ZombieBotBehavior:GetRandomPreferedClass()
    local _, Class = table.Random(ZombieBotBehavior.PreferedClasses)

    return class
end
function ZombieBotBehavior:CriticalHealthBehavior(Bot)
end
function ZombieBotBehavior:CriticalArmorBehavior(Bot)
end
function ZombieBotBehavior:GetNearstEnemy(Bot, DistanceFilter, PathLengthFilter)
end
function ZombieBotBehavior:CloseToEnemyBehavior(Bot, Enemy)
end


hook.Add("ZPEndRound", "BotNewClassChoose", function()
    local BotPlayers = BotManager:GetBotPlayers()

    for K, Bot in pairs(BotPlayers) do
        if math.random(1, 1) == 1 then
            local NewClass = Bot:GetHumanBotBehavior():GetRandomPreferedClass()
            ClassManager:SetZPClass(Bot, NewClass, TEAM_HUMANS)
        end
        if math.random(1, 1) == 1 then
            local NewClass = Bot:GetZombieBotBehavior():GetRandomPreferedClass()
            ClassManager:SetZPClass(Bot, NewClass, TEAM_ZOMBIES)
        end
    end
end)

hook.Add("ZPZombieInflictedDamageOnPlayer", "BotHumanDamageEvent", function(Attacker, Target, DmgInfo)
    if BotManager:IsBot(Target) then
        local Behavior = Target:GetHumanBotBehavior()
        if Target:Armor() > 0 && Target:Armor() < 10 then
            Behavior:CriticalArmorBehavior(Target)
        elseif Target:Health() < math.floor(Target:GetMaxHealth() / 10) then
            Behavior:CriticalHealthBehavior(Target)
        end
    end
end)
hook.Add("ZPHumanInflictedDamageOnPlayer", "BotZombieDamageEvent", function(Attacker, Target, DmgInfo)
    if BotManager:IsBot(Target) then
        local Behavior = Target:GetZombieBotBehavior()
        if Target:Armor() > 0 && Target:Armor() < 10 then
            Behavior:CriticalArmorBehavior(Target)
        elseif Target:Health() < math.floor(Target:GetMaxHealth() / 10) then
            Behavior:CriticalHealthBehavior(Target)
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

Commands:AddCommand({"bot"}, "Add a simple bot", function(Ply, Args)
    if Args[1] == "add" then
        if !Args[2] then
            local Bot = BotManager:CreateIntelligentBot(nil)

            RoundManager:AddPlayerToPlay(Bot)
        end

        local AmountToAdd = tonumber(Args[2])
        if AmountToAdd then
            for i = 1, AmountToAdd do
                local Bot = BotManager:CreateIntelligentBot(nil)

                RoundManager:AddPlayerToPlay(Bot)
            end
        else
            local Bot = BotManager:CreateIntelligentBot(Args[2])

            RoundManager:AddPlayerToPlay(Bot)
        end
    end
end)