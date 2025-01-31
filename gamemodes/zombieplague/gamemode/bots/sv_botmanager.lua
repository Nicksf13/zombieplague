include("svhk_botmanager.lua")

ConvarManager:CreateConVar("zp_zombie_forget_target_time", 10, 8, "cvar used to define how long will take to the zombie bot forget the target (not appliable for all the zombies)")
ConvarManager:CreateConVar("zp_bot_next_segment_draw", 0, 8, "cvar used to define if the server should draw the bot's path next segment")
ConvarManager:CreateConVar("zp_bot_distance_to_position_draw", 0, 8, "cvar used to define if the server should draw the distance is being calculated")
ConvarManager:CreateConVar("zp_bot_farest_area_draw", 0, 8, "cvar used to define if the server should draw the farest area")

BotManager = {}
ZombieBotBehavior = {}

BotManager.Config = {
    ReservedSlots = 0,
    TotalBots = 0
}
BotManager.HidingSpotsToUse = {}
BotManager.RandomHidingSpotsList = {}
BotManager.HumanBehaviors = {}
BotManager.ZombieBehaviors = {}
BotManager.NameList = {
    "Eric",
    "Fire",
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
    "2 late 2 sea",
    "Athena",
    "Scooby",
    "Nameless",
    "Wazzup",
    "Squid"
}

function BotManager:Initialize()
    local Files = Utils:RecursiveFileSearch("zombieplague/gamemode/bots/behaviors/zombies", ".lua")
	if Files then
		for k, File in pairs(Files) do
			ZombieBotBehavior = BotManager:NewZombieBehavior()
			include(File)

            table.insert(BotManager.ZombieBehaviors, ZombieBotBehavior)
		end
	end
	
	Files = Utils:RecursiveFileSearch("zombieplague/gamemode/bots/behaviors/humans", ".lua")
	if Files then
		for k, File in pairs(Files) do
			HumanBotBehavior = BotManager:NewHumanBehavior()
			include(File)

            table.insert(BotManager.HumanBehaviors, HumanBotBehavior)
		end
	end
end
function BotManager:RequestNewPlayer(BotAdder, Name)
    if #player.GetAll() < BotManager:GetAvailableSlots() then
        BotManager:AddPlayer(Name)

        self.Config.TotalBots = self.Config.TotalBots + 1
    else
        SendPopupMessage(BotAdder, "You can't add more bots, as the max player limit has been reached")
    end
end
function BotManager:RemoveBot()
    local BotPlayers = BotManager:GetBotPlayers()

    local Bot, _ = table.Random(BotPlayers)

    Bot:Kick("Kicking Bot")
    self.Config.TotalBots = self.Config.TotalBots - 1
end
function BotManager:AddPlayer(Name)
    local Bot = BotManager:CreateIntelligentBot(Name)

    Bot:SetAmmoPacks(Bank.BankStorageSource:GetPlayerAmmopacks(Bot), true)

    RoundManager:AddPlayerToPlay(Bot)
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
    if !IsValid(Bot) then
        return
    end

    local PathFinder = Bot:GetPathFinder()

    Cmd:ClearButtons()
    Cmd:ClearMovement()
    Cmd:SetButtons(PathFinder:GetKeys())
end
function BotManager:HandleStartCommand(Bot, Mv, Cmd)
    if !IsValid(Bot) then
        return
    end

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
        if cvars.Bool("zp_bot_next_segment_draw", false) then
            NextSegment.area:Draw()
        end
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
    if IsValid(Enemy) then
        ViewAngle = LerpAngle(1, Bot:EyeAngles(), (Enemy:GetShootPos() - Bot:GetShootPos()):Angle())
        if Behavior:ShouldAttack(Bot, Enemy) then
            Keys = Behavior:AttackBehavior(Bot, Enemy, Keys)
        end
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

    local PlayerTable = Bot:IsHuman() and RoundManager:GetAliveZombies() or RoundManager:GetAliveHumans()

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
    if cvars.Bool("zp_bot_distance_to_position_draw", false) then
        Path:Draw() 
    end

    return Length
end
function BotManager:IsBot(Ply)
    return IsValid(Ply) && Ply:IsPlayer() && Ply:IsBot()
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
function BotManager:ResetPathFinder(Player)
    local PathFinder = Player:GetPathFinder()

    PathFinder:SetTargetPos(nil)
    PathFinder:SetEnemy(nil)
    PathFinder:SetTargetPos(nil)
    PathFinder:SetForgetEnemyTime(nil)
end
function BotManager:NewHumanBehavior()
    HumanBotBehavior = {}
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

        if !IsValid(Enemy) || !Bot:Visible(Enemy) then
            PathFinder:SetEnemy(nil)
        end
    end
    function HumanBotBehavior:ShouldAttack(Bot, Enemy)
        local PathFinder = Bot:GetPathFinder()
        local Distance = Bot:GetPos():Distance(Enemy:GetPos())
        local ShootRange = WeaponManager:GetBotShootRange(Bot)
    
        if Distance < ShootRange then
            return true
        end

        return false
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
        if CurTime() >= Bot:GetNextCriticalHealthActionTime() then
            local ArmorExtraItem = ExtraItemsManager:GetItemById(Bot:Team(), "ZPArmor")

            if ArmorExtraItem && Bot:GetAmmoPacks() >= ArmorExtraItem.Price then
                ExtraItemsManager:BuyItem(Bot, ArmorExtraItem)

                Bot:SetNextCriticalHealthActionTime(CurTime() + 5) 
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

    return HumanBotBehavior
end
function BotManager:NewZombieBehavior()
    ZombieBotBehavior.PreferedClasses = {
        "ZombieJumperClassName",
        "ZombieLightClassName",
        "ZombieSpeedClassName",
        "ZombieLeechClassName"
    }
    
    function ZombieBotBehavior:MovementBehavior(Bot)
        local PathFinder = Bot:GetPathFinder()
        local CurrentEnemy = PathFinder:GetEnemy()
    
        if IsValid(CurrentEnemy) then
            PathFinder:SetTargetPos(CurrentEnemy:GetPos())
        elseif !PathFinder:GetTargetPos() then
            local RandomHidingSpot = BotManager:FindRandomHidingSpot()
    
            PathFinder:SetTargetPos(RandomHidingSpot)
        end
    end
    function ZombieBotBehavior:SearchForEnemyBehavior(Bot)
        local PathFinder = Bot:GetPathFinder()
        local CurrentEnemy = PathFinder:GetEnemy()
    
        if IsValid(CurrentEnemy) then
            if CurTime() >= Bot:GetNextTargetChooseTime()  then
                local NearstEnemy = BotManager:GetNearstEnemy(Bot, 300)
                
                if NearstEnemy && NearstEnemy != CurrentEnemy then
                    CurrentEnemy = NearstEnemy
    
                    PathFinder:SetEnemy(NearstEnemy)
                    Bot:SetNextTargetChooseTime(CurTime() + 5)
                end
            end
    
            if Bot:Visible(CurrentEnemy) then
                PathFinder:SetForgetEnemyTime(CurTime() + cvars.Number("zp_zombie_forget_target_time", 10))
            end
        else
            local NearstEnemy = BotManager:GetNearstEnemy(Bot, 100000)
        
            if NearstEnemy then
                PathFinder:SetForgetEnemyTime(CurTime() + cvars.Number("zp_zombie_forget_target_time", 10))
    
                PathFinder:SetEnemy(NearstEnemy)
            end
        end
    end
    function ZombieBotBehavior:ForgetEnemyBehavior(Bot)
        local PathFinder = Bot:GetPathFinder()
    
        if PathFinder:GetForgetEnemyTime() && PathFinder:GetForgetEnemyTime() < CurTime() then
            BotManager:ResetPathFinder(Bot)
        end
    end
    function ZombieBotBehavior:ShouldAttack(Bot, Enemy)
        local PathFinder = Bot:GetPathFinder()
        local Distance = Bot:GetPos():Distance(Enemy:GetPos())
    
        if Distance < 100 then
            return true
        end

        return false
    end
    function ZombieBotBehavior:AttackBehavior(Bot, Enemy, Keys)
        return Keys + IN_ATTACK
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
        local ZombieMadnessIdentifier = Bot:ZombieMadnessIdentifier()
    
        if !timer.Exists(ZombieMadnessIdentifier) then
            local ZombieMadnessItem = ExtraItemsManager:GetItemById(Bot:Team(), "ZPZombieMadness")
    
            if ZombieMadnessItem && Bot:GetAmmoPacks() >= ZombieMadnessItem.Price then
                ExtraItemsManager:BuyItem(Bot, ZombieMadnessItem)
            end
        end
    end
    function ZombieBotBehavior:CriticalArmorBehavior(Bot)
    end
    function ZombieBotBehavior:GetNearstEnemy(Bot, DistanceFilter, PathLengthFilter)
    end
    function ZombieBotBehavior:CloseToEnemyBehavior(Bot, Enemy)
    end

    return ZombieBotBehavior
end
function BotManager:GetAvailableSlots()
    return game.MaxPlayers() - self.Config.ReservedSlots
end
function BotManager:SetTotalBots(TotalBots)
    self.Config.TotalBots = TotalBots

    BotManager:AdjustBotPlayers()
end
function BotManager:AdjustBotPlayers()
    local TotalBots = self.Config.TotalBots
    local AvailableBotSlots = BotManager:GetAvailableSlots()
    local MaxBots = TotalBots > AvailableBotSlots and AvailableBotSlots or TotalBots
    local BotPlayersCount = #player.GetBots()

    if BotPlayersCount > MaxBots then
        local BotsToRemove = BotPlayersCount - MaxBots

        timer.Create("KickBotEvent", 0.1, BotsToRemove, function()
            BotManager:RemoveBot()
        end)
    elseif BotPlayersCount < MaxBots then
        local BotsToAdd = MaxBots - BotPlayersCount
        local AvailableSlots = game.MaxPlayers() - #player.GetAll()

        if BotsToAdd > AvailableSlots then
            BotsToAdd = AvailableSlots
        end

        timer.Create("JoinBotEvent", 0.1, BotsToAdd, function()
            BotManager:AddPlayer()
        end)
    end
end

Commands:AddCommand({"bot_add"}, "Add a simple bot", function(Ply, Args)
    BotManager:AddPlayer(Ply)
end)
Commands:AddCommand({"bot_set"}, "Set the number of bots in the server. It will ignore reserved slots if max is reached", function(Ply, Args)
    local TotalBots = tonumber(Args[1])
    if TotalBots then
        BotManager:SetTotalBots(TotalBots)
    else
        SendPopupMessage(Ply, "The second argument must be a number!")
    end
end)

Commands:AddCommand({"bot_remove"}, "Remove a random bot", function(Ply, Args)
    BotManager:RemoveBot()
end)