DCenteredLabel = {}

function DCenteredLabel:Init()
    local TextLabel = vgui.Create("DLabel", self)
    TextLabel:SetPos(0, 0)
    TextLabel:SetSize(200, 30)
    TextLabel:SetFont("Trebuchet24")
    TextLabel:SetText("")

    self.TextLabel = TextLabel

    function self:RecalculateTextPostion()
        self:CalculateTextSize()
    
        local TextWidth = self:GetTextWidth()
        local TextHeight = self:GetTextHeight()
        local PossibleTextWidth = self:GetWide() - (self:GetBorderSize() * 2)
        local PossibleTextHeight = self:GetTall() - (self:GetBorderSize() * 2)
        local MissingWidthSpace = PossibleTextWidth - TextWidth
        local MissingHeightSpace = PossibleTextHeight - TextHeight
    
        if MissingWidthSpace < 0 then
            MissingWidthSpace = 0
        end
    
        if MissingHeightSpace < 0 then
            MissingHeightSpace = 0
        end
    
        local PosX = self:GetBorderSize() + math.floor(MissingWidthSpace / 2)
        local PosY = self:GetBorderSize() + math.floor(MissingHeightSpace / 2)
    
        local TextLabel = self.TextLabel
        TextLabel:SetSize(TextWidth, TextHeight)
        TextLabel:SetPos(PosX, PosY)
    end
    function self:CalculateTextSize()
        local Width, Height = HudManager:CalculateTextSize(self:GetText(), self:GetFont())
    
        if Width > self:GetTextMaxWidth() then
            Width = self:GetTextMaxWidth()
        end
    
        local ComponentWidthWithoutBorder = self:GetWide() - (self:GetBorderSize() * 2)
        if Width > ComponentWidthWithoutBorder then
            Width = ComponentWidthWithoutBorder
        end
    
        self:SetTextWidth(Width)
    
        local ComponentHeightWithoutBorder = self:GetTall() - (self:GetBorderSize() * 2)
        if Height > ComponentHeightWithoutBorder then
            Height = ComponentHeightWithoutBorder
        end
    
        self:SetTextHeight(Height)
    end
    
    function self:SetTextAndFont(Text, Font)
        self.TextLabel:SetText(Text)
        self.TextLabel:SetFont(Font)
    
        self:RecalculateTextPostion()
    end
    function self:SetBackgroundColor(BackgroundColor)
        self.BackgroundColor = BackgroundColor
    end
    function self:GetBackgroundColor()
        return self.BackgroundColor or Color(0, 0, 0, 0)
    end
    function self:SetBorderColor(BorderColor)
        self.BorderColor = BorderColor
    end
    function self:GetBorderColor()
        return self.BorderColor or Color(0, 0, 0, 0)
    end
    function self:SetBorderSize(BorderSize)
        self.BorderSize = BorderSize
    
        self:RecalculateTextPostion()
    end
    function self:GetBorderSize()
        return self.BorderSize or 0
    end
    function self:SetCornerRadius(CornerRadius)
        self.CornerRadius = CornerRadius
    end
    function self:GetCornerRadius()
        return self.CornerRadius or 0
    end
    function self:SetText(Text)
        self.TextLabel:SetText(Text)
    
        self:RecalculateTextPostion()
    end
    function self:GetText()
        return self.TextLabel:GetText()
    end
    function self:SetTextColor(Color)
        self.TextLabel:SetTextColor(Color)
    end
    function self:SetFont(Font)
        self.TextLabel:SetFont(Font)
    
        self:RecalculateTextPostion()
    end
    function self:GetFont()
        return self.TextLabel:GetFont()
    end
    function self:SetTextMaxWidth(MaxWidth)
        self.MaxWidth = MaxWidth
    
        self:RecalculateTextPostion()
    end
    function self:GetTextMaxWidth()
        return self.MaxWidth or self:GetWide()
    end
    function self:SetTextWidth(TextWidth)
        self.TextWidth = TextWidth > 0 and TextWidth or 0
    end
    function self:GetTextWidth()
        return self.TextWidth or 200
    end
    function self:SetTextHeight(TextHeight)
        self.TextHeight = TextHeight > 0 and TextHeight or 0
    end
    function self:GetTextHeight()
        return self.TextHeight or 30
    end

    function self:PerformLayout(Width, Height)
        self:RecalculateTextPostion()
    end
end
function DCenteredLabel:Paint(Width, Height)
    HudManager:CreateBox(self:GetBorderSize(), self:GetCornerRadius(), self:GetBorderColor(), self:GetBackgroundColor(), 0, 0, Width, Height)
end

vgui.Register("DCenteredLabel", DCenteredLabel, "DPanel")