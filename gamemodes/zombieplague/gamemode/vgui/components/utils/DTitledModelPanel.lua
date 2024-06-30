NO_ANIMATION = 0
ANIMATION_HOVER_ONLY = 1

NO_ROTATION = 0
ROTATION_HOVER_ONLY = 1
ALWAYS_ROTATE = 2

DTitledModelPanel = {}

function DTitledModelPanel:Init()
    local Self = self
    local ModelVisualizer = vgui.Create("DModelPanel", self)
    local TitleLabel = vgui.Create("DCenteredLabel", self)
    local BodyPanel = vgui.Create("DPanel", self)

    ModelVisualizer:SetZPos(10)

    function BodyPanel:Paint(Width, Height) end

    Self.ModelVisualizer = ModelVisualizer
    Self.TitleLabel = TitleLabel
    Self.BodyPanel = BodyPanel
    Self.AnimationTrigger = NO_ANIMATION
    Self.RotationType = NO_ROTATION
    Self.Hovered = false

    function ModelVisualizer:OnCursorEntered()
        Self.Hovered = true

        Self:SetTitleHoveredBackgroundColor(Self:GetTitleHoveredBackgroundColor())

        if Self:GetAnimationTrigger() == ANIMATION_HOVER_ONLY && Self:GetSequenceName() then
            Self:PlayAnimation(Self:GetSequenceName()) 
        end

        if Self.OnCursorEnteredFunction then
            Self:OnCursorEnteredFunction()
        end
    end
    function ModelVisualizer:OnCursorExited()
        Self.Hovered = false
        
        Self:SetTitleBackgroundColor(Self:GetTitleBackgroundColor())

        Self:ResetAnimation()
    end

    function ModelVisualizer:LayoutEntity(ent)
        if Self:GetRotationType() == ALWAYS_ROTATE || Self:GetRotationType() == ROTATION_HOVER_ONLY && Self:IsHovered() then
            ent:SetAngles(Angle(0, RealTime() * 50, 0))
        end
    end
    ModelVisualizer.DoClick = function()
        if Self.DoClickFunction then
            Self.DoClickFunction()
        end
    end

    function self:PlayAnimation(SequenceName)
        local Ent = self.ModelVisualizer:GetEntity()
        if IsValid(Ent) then
            local AnimationId, _ = Ent:LookupSequence(SequenceName)
            
            Ent:SetSequence(AnimationId)
            Ent:ResetSequence(AnimationId)
            Ent:ResetSequenceInfo()
            Ent:SetCycle(0)
            self.ModelVisualizer:RunAnimation()
        end
    end
    function self:ResetAnimation()
        local IdleSequenceName = Self:GetIdleSequenceName()
        if IdleSequenceName then
            Self:PlayAnimation(IdleSequenceName)
        end
    end
    function self:SetModel(Model)
        local ModelVisualizer = Self.ModelVisualizer
        ModelVisualizer:SetModel(Model)
    
        local PrevMins, PrevMaxs = ModelVisualizer.Entity:GetRenderBounds()
        ModelVisualizer:SetCamPos(PrevMins:Distance(PrevMaxs) * Vector(0.6, 0.6, 0.6))
        ModelVisualizer:SetLookAt((PrevMaxs + PrevMins) / 2)
    end
    function self:SetSequenceName(SequenceName)
        Self.SequenceName = SequenceName
    end
    function self:GetSequenceName()
        return Self.SequenceName
    end
    function self:SetIdleSequenceName(IdleSequenceName)
        Self.IdleSequenceName = IdleSequenceName
    end
    function self:GetIdleSequenceName()
        return Self.IdleSequenceName
    end
    function self:SetAnimationTrigger(AnimationTrigger)
        Self.AnimationTrigger = AnimationTrigger
    
        Self.ModelVisualizer:SetAnimated(AnimationTrigger == NO_ANIMATION)
    end
    function self:GetAnimationTrigger()
        return Self.AnimationTrigger
    end
    function self:SetRotationType(RotationType)
        Self.RotationType = RotationType
    end
    function self:GetRotationType()
        return Self.RotationType
    end
    function self:IsHovered()
        return Self.Hovered
    end
    function self:SetTitleFont(Font)
        Self.TitleLabel:SetFont(Font)
    end
    function self:SetHoveredBodyBackgroundColor(HoveredBodyBackgroundColor)
        Self.HoveredBodyBackgroundColor = HoveredBodyBackgroundColor
    end
    function self:SetBodyBackgroundColor(BackgroundColor)
        Self.BodyBackGroundColor = BackgroundColor
    end
    function self:SetTitleHoveredBackgroundColor(HoveredBackgroundColor)
        Self.TitleHoveredBackgroundColor = HoveredBackgroundColor
        Self.TitleLabel:SetBackgroundColor(HoveredBackgroundColor)
    end
    function self:SetTitleBackgroundColor(BackgroundColor)
        Self.TitleBackgroundColor = BackgroundColor
        Self.TitleLabel:SetBackgroundColor(BackgroundColor)
    end
    function self:GetTitleHoveredBackgroundColor()
        return Self.TitleHoveredBackgroundColor
    end
    function self:GetTitleBackgroundColor()
        return Self.TitleBackgroundColor
    end
    function self:SetTitle(Title)
        Self.TitleLabel:SetText(Title)
    end
    function self:SetOnCursorEnteredFunction(OnCursorEnteredFunction)
        Self.OnCursorEnteredFunction = OnCursorEnteredFunction
    end
    function self:SetDoClickFunction(DoClickFunction)
        Self.DoClickFunction = DoClickFunction
    end
    function self:GetBody()
        return Self.BodyPanel
    end
    function self:Paint(Width, Height)
        if self:IsHovered() then
            HudManager:CreateBox(0, 0, Color(0, 0, 0, 0), Self.HoveredBodyBackgroundColor, 0, 0, Width, Height)
        else
            HudManager:CreateBox(0, 0, Color(0, 0, 0, 0), Self.BodyBackGroundColor, 0, 0, Width, Height)
        end
    end
    function self:PerformLayout(Width, Height)
        local TitleHeight = 30
        self.TitleLabel:SetSize(Width, TitleHeight)
        self.BodyPanel:SetSize(Width, Height - TitleHeight)
        self.BodyPanel:SetPos(0, TitleHeight)
        self.ModelVisualizer:SetSize(Width, Height)
    end

    self:SetHoveredBodyBackgroundColor(Color(26, 197, 219, 120))
    self:SetBodyBackgroundColor(Color(202, 195, 195))
    self:SetTitleHoveredBackgroundColor(Color(0, 0, 0, 180))
    self:SetTitleBackgroundColor(Color(0, 0, 0, 180))

    Self:PlayAnimation(ACT_IDLE)
    Self.ModelVisualizer:SetAnimated(false)
end

vgui.Register("DTitledModelPanel", DTitledModelPanel, "DPanel")