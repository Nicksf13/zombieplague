local ScrWidth = 600
local ScrHeight = 600
local ScoreBoardManager = {CompPosX = 20, CompPosY = 20, UpdateComponents = {}}

function ScoreBoardManager:CreateScoreboard()
    self.CompPosX = 20
    self.CompPosY = 20
    
    local BorderColor = Color(0, 0, 0, 0)
    local BackGroundColor = Color(0, 0, 0, 250)
    local ScoreBoard = vgui.Create("DFrame")
    ScoreBoard:SetDraggable(false)
    ScoreBoard:ShowCloseButton(false)
    ScoreBoard:SetDeleteOnClose(true)
    ScoreBoard:SetTitle("")
    ScoreBoard:SetSize(ScrWidth, ScrHeight)
    ScoreBoard:Center()

    function ScoreBoard:Paint(Width, Height)
        HudManager:CreateBox(0, 2, BorderColor, BackGroundColor, 0, 0, Width, Height)
    end

    local Scroll = vgui.Create("DScrollPanel", ScoreBoard)
    Scroll:SetPos(0, self.CompPosY)
    Scroll:SetSize(ScrWidth, ScrHeight - (self.CompPosY * 2))
    function Scroll:Paint()end

    self.Scroll = Scroll
    self.ScoreBoard = ScoreBoard

    ScoreBoardManager:FillScroll(Scroll)

    ScoreBoardManager:AddComponentToListening(Scroll, function()
            return Scroll.TotalHumans != table.Count(team.GetPlayers(TEAM_HUMANS)) ||
            Scroll.TotalZombies != table.Count(team.GetPlayers(TEAM_ZOMBIES)) ||
            Scroll.TotalSpectators != table.Count(team.GetPlayers(TEAM_SPECTATOR))
        end, 
        function()
            ScoreBoardManager:FillScroll(Scroll)
        end
    )

    ScoreBoard:MakePopup(true)

    timer.Create("ScoreBoardUpdater", 1, 0, function()
        for k, ComponentUpdate in pairs(ScoreBoardManager.UpdateComponents) do
            if !IsValid(ComponentUpdate.Component) then
                ScoreBoardManager.UpdateComponents[k] = nil
            elseif ComponentUpdate:ShouldUpdateFunction() then
                ComponentUpdate:UpdateFunction()
            end
        end
    end)
end

function ScoreBoardManager:FillScroll(Scroll)
    self.CompPosY = 0
    Scroll:Clear()
    
    Scroll.TotalHumans = table.Count(team.GetPlayers(TEAM_HUMANS))
    Scroll.TotalZombies = table.Count(team.GetPlayers(TEAM_ZOMBIES))
    Scroll.TotalSpectators = table.Count(team.GetPlayers(TEAM_SPECTATOR))

    if Scroll.TotalHumans > 0 then
        ScoreBoardManager:AddComponent(ScoreBoardManager:CreateTeamPlayerTable(TEAM_HUMANS), 10)
    end
    if Scroll.TotalZombies > 0 then
        ScoreBoardManager:AddComponent(ScoreBoardManager:CreateTeamPlayerTable(TEAM_ZOMBIES), 10)
    end
    if Scroll.TotalSpectators > 0 then
        ScoreBoardManager:AddComponent(ScoreBoardManager:CreateTeamPlayerTable(TEAM_SPECTATOR), 0)
    end
end

function ScoreBoardManager:CreateTeamPlayerTable(Team)
    local TitleText = ScoreBoardManager:GetTeamName(Team)
    local TitleFont = "DermaLarge"

    local DTeamPanel = vgui.Create("DPanel")
    DTeamPanel.Paint = function()end
    DTeamPanel.TotalComponentHeight = 0
    function DTeamPanel:AddComponent(Component, PaddingBottom)
        Component:SetPos(0, self.TotalComponentHeight)
        local W, H = Component:GetSize()

        self:Add(Component)
        self.TotalComponentHeight = self.TotalComponentHeight + H + (PaddingBottom or 0)
    end

    ScoreBoardManager:FillTable(DTeamPanel, TitleText, TitleFont, Team)

    return DTeamPanel
end

function ScoreBoardManager:GetTeamName(Team)
    if Team == TEAM_HUMANS then
        return Dictionary:GetPhrase("ScoreBoardTitleHumans")
    end

    if Team == TEAM_ZOMBIES then
        return Dictionary:GetPhrase("ScoreBoardTitleZombies")
    end

    return Dictionary:GetPhrase("ScoreBoardTitleSpectators")
end

function ScoreBoardManager:FillTable(Table, TitleText, TitleFont, Team)
    Table.TotalPlayers = table.Count(team.GetPlayers(Team))
    Table.TotalComponentHeight = 0
    Table:Clear()

    local TeamColor = team.GetColor(Team)

    local DTitle = vgui.Create("DLabel")
    DTitle:SetText(TitleText)
    DTitle:SetFont(TitleFont)
    DTitle:SetSize(HudManager:CalculateTextSize(TitleText, TitleFont))

    Table:AddComponent(DTitle)

    local Header = ScoreBoardManager:CreatePlayerLine(
        Dictionary:GetPhrase("ScoreBoardHeaderName"),
        Dictionary:GetPhrase("ScoreBoardHeaderPoints"),
        Dictionary:GetPhrase("ScoreBoardHeaderDeaths"),
        Dictionary:GetPhrase("ScoreBoardHeaderStatus"),
        Dictionary:GetPhrase("ScoreBoardHeaderPing"),
        "",
        "DermaDefault",
        TeamColor
    )
    Table:AddComponent(Header, 0)
    Table:AddComponent(ScoreBoardManager:CreateLine(4, ScrWidth - (self.CompPosX * 2), 2, TeamColor), 0)

    local PlayersSorted = team.GetPlayers(Team)

    table.sort(PlayersSorted, function(PlyA, PlyB) return PlyA:GetPoints() > PlyB:GetPoints() end)

    for i, ply in ipairs(PlayersSorted) do
        if ply && IsValid(ply) then
            local NewPlayerLine = ScoreBoardManager:CreatePlayerLine(
                function() return (ply && IsValid(ply)) and ply:Name() or "" end,
                function() return (ply && IsValid(ply)) and ply:GetPoints() or "" end,
                function() return (ply && IsValid(ply)) and ply:Deaths() or "" end,
                function()
                    if !ply || !IsValid(ply) then
                        return ""
                    end
                    if ply:Team() == TEAM_SPECTATOR then
                        return Dictionary:GetPhrase("ScoreBoardStatusSpectating")
                    end
                    if ply:Alive() then
                        return Dictionary:GetPhrase("ScoreBoardStatusAlive")
                    end
                    return Dictionary:GetPhrase("ScoreBoardStatusDead")
                end,
                function() return (ply && IsValid(ply)) and ply:Ping() or "" end,
                ply,
                "DermaDefault",
                TeamColor
            )
            Table:AddComponent(NewPlayerLine, 0)
        end
    end

    Table:SetSize(ScrWidth, Table.TotalComponentHeight)
end

function ScoreBoardManager:CreatePlayerLine(Name, Points, Deaths, Status, Ping, PlyMuted, TextFont, TeamColor)
    local PlayerLine = vgui.Create("DPanel")
    PlayerLine:SetSize(ScrWidth, 20)
    PlayerLine.Paint = function()end

    PlayerLine:Add(ScoreBoardManager:CreateCenteredLabel(Name, TextFont, TeamColor, 0, 190))
    PlayerLine:Add(ScoreBoardManager:CreateCenteredLabel(Points, TextFont, TeamColor, 200, 80))
    PlayerLine:Add(ScoreBoardManager:CreateCenteredLabel(Deaths, TextFont, TeamColor, 290, 80))
    PlayerLine:Add(ScoreBoardManager:CreateCenteredLabel(Status, TextFont, TeamColor, 380, 70))
    PlayerLine:Add(ScoreBoardManager:CreateCenteredLabel(Ping, TextFont, TeamColor, 460, 80))
    
    if type(PlyMuted) != "string" && IsValid(PlyMuted) && PlyMuted != LocalPlayer() then
        local Mute = vgui.Create("DButton")
        Mute:SetSize(20, 20)
        Mute:SetImage(!PlyMuted:IsMuted() and "icon16/sound.png" or "icon16/sound_mute.png")
        Mute:SetPos(530, 0)
        Mute:SetText("")
        function Mute:DoClick()
            PlyMuted:SetMuted(!PlyMuted:IsMuted())
            Mute:SetImage(!PlyMuted:IsMuted() and "icon16/sound.png" or "icon16/sound_mute.png")
        end
        function Mute:Paint(Width, Heigth)end
        PlayerLine:Add(Mute)
    end

    return PlayerLine
end

function ScoreBoardManager:CreateLine(CornerRadius, LineWidth, LineHeight, LineColor)
    local SimpleLine = vgui.Create("DPanel")
    SimpleLine:SetSize(LineWidth, LineHeight)
    function SimpleLine:Paint(Width, Heigth)
        HudManager:CreateBox(0, 2, nil, LineColor, 0, 0, Width, Heigth)
    end

    return SimpleLine
end

function ScoreBoardManager:CreateCenteredLabel(Text, TextFont, TeamColor, InitialPosX, MaxTextSize)
    local Label = vgui.Create("DLabel")
    local NewText = Text
    if type(Text) == "function" then
        NewText = Text()

        ScoreBoardManager:AddComponentToListening(Label, function()
                return true
            end, 
            function()
                ScoreBoardManager:CenterLabel(Label, Text(), TextFont, InitialPosX, MaxTextSize)
            end
        )
    end

    ScoreBoardManager:CenterLabel(Label, NewText, TextFont, InitialPosX, MaxTextSize)

    Label:SetFont(TextFont)
    Label:SetColor(TeamColor)

    return Label
end

function ScoreBoardManager:CenterLabel(Label, Text, TextFont, InitialPosX, MaxTextSize)
    local Width = HudManager:CalculateTextSize(Text, TextFont)
    if Width > MaxTextSize then
        Width = MaxTextSize
    end

    local PosX = InitialPosX + ((MaxTextSize - Width) / 2)

    Label:SetSize(Width, 25)
    Label:SetPos(PosX, 0)
    Label:SetText(Text)
end

function ScoreBoardManager:AddSpace(SpaceSize)
    self.CompPosY = self.CompPosY + SpaceSize
end

function ScoreBoardManager:AddComponent(Component, Padding)
    Component:SetPos(self.CompPosX, self.CompPosY)

    self.Scroll:Add(Component)

    local W, H = Component:GetSize()

    ScoreBoardManager:AddSpace(H + Padding)
end

function ScoreBoardManager:AddComponentToListening(Component, ShouldUpdateFunction, UpdateFunction)
    table.insert(ScoreBoardManager.UpdateComponents, {
        Component = Component,
        ShouldUpdateFunction = ShouldUpdateFunction,
        UpdateFunction = UpdateFunction
    })
end

function GM:ScoreboardShow()
	ScoreBoardManager:CreateScoreboard()
end

function GM:ScoreboardHide()
    ScoreBoardManager.UpdateComponents = {}
    timer.Destroy("ScoreBoardUpdater")

    ScoreBoardManager.ScoreBoard:Close()
	ScoreBoardManager.ScoreBoard = nil
end