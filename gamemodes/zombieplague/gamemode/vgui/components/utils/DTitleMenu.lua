TitleMenu = {}

function TitleMenu:Init()
    local BasicConfiguration = TitleMenu:GenerateBasicConfiguration()
    local BodyConfiguration = BasicConfiguration.BodyConfiguration

    local Width = BasicConfiguration.Width
    local Height = BasicConfiguration.Height

    self:SetDraggable(false)
    self:ShowCloseButton(false)
    self:SetDeleteOnClose(true)
    self:SetSize(Width, Height)
    self:SetTitle("")
    self:Center()
    self:SetSizable(true)
    self.BasicConfiguration = BasicConfiguration

    self:MakePopup()

    function self:SetContent(Content)
        local BodyConfiguration = BasicConfiguration.BodyConfiguration
        local Width = BodyConfiguration.Width
        local Height = BodyConfiguration.Height
        local XPos = BodyConfiguration.XPos
        local YPos = BodyConfiguration.YPos
    
        local Body = vgui.Create("DPanel", self)
        Body:SetSize(Width, Height)
        Body:SetPos(XPos, YPos)
        Body:Add(Content)
        function Body:Paint(Width, Height)end
    end
    function self:SetBorderColor(BorderColor)
        self.BorderColor = BorderColor
    end
    function self:SetBackgroundColor(BackgroundColor)
        self.BackgroundColor = BackgroundColor
    end
    function self:CreateTitle()
        local TitleLabel = vgui.Create("DLabel", self)
        TitleLabel:SetFont(InterfaceConfiguration["Title"].Font)
        TitleLabel:SetPos(10, 5)
        TitleLabel:SetSize(300, 40)
    
        self.TitleLabel = TitleLabel
    end
    function self:SetTitleText(TitleText)
        self.TitleLabel:SetText(TitleText)
    end
    
    function self:CreateCloseButton(DFrameObject)
        local CloseButtonConfiguration = BasicConfiguration.CloseButtonConfiguration
        local ScrWidth = BasicConfiguration.Width
        local ButtonWidth = CloseButtonConfiguration.Width
        local ButtonHeight = CloseButtonConfiguration.Height
        local Font = CloseButtonConfiguration.Font
        local BackgroundColor = CloseButtonConfiguration.BackgroundColor
    
        local Teste = TitleMenu
    
        local CloseButton = vgui.Create("DButton", self)
        CloseButton:SetSize(ButtonWidth, ButtonHeight)
        CloseButton:SetPos(ScrWidth - ButtonWidth, 0)
        CloseButton:SetFont(Font)
        CloseButton:SetText("X")	
        function CloseButton:Paint(Width, Height)
            HudManager:CreateBox(0, 0, Color(0, 0, 0, 0), BackgroundColor, 0, 0, Width, Height)
        end
    
        function CloseButton:DoClick()
            DFrameObject:Close()
    
            if self.CloseFunction then
                self.CloseFunction()
            end
        end
    end
    
    function self:SetCloseFunction(CloseFunction)
        self.CloseFunction = CloseFunction
    end

    self:SetBorderColor(BasicConfiguration.BorderColor)
    self:SetBackgroundColor(BasicConfiguration.BackgroundColor)

    self:CreateTitle()
    self:CreateCloseButton(self)
end
function TitleMenu:Paint(Width, Height)
    HudManager:CreateBox(0, 2, self.BorderColor, self.BackgroundColor, 0, 0, Width, Height)
end
function TitleMenu:GenerateBasicConfiguration()
    local BorderSize = 20
    local BodyYPos = 60
    local ScreenWidth = ScrW() / 1.5
    local ScreenHeight = ScrH() / 1.2
    if ScreenWidth < 800 then
        ScreenWidth = 800
    end
    if ScreenHeight < 600 then
        ScreenHeight = 600
    end

    local BodyConfiguration = {
        XPos = BorderSize,
        YPos = BodyYPos,
        Width = ScreenWidth - (BorderSize * 2),
        Height = ScreenHeight - BorderSize - BodyYPos
    }

    local CloseButtonConfiguration = {
        BackgroundColor = Color(255, 0, 0, 250),
        Font = "Trebuchet24",
        Width = 80,
        Height = 30
    }

    local BasicConfiguration = {
        Width = ScreenWidth,
        Height = ScreenHeight,
        BorderColor = Color(0, 0, 0, 250),
        BackgroundColor = Color(0, 0, 0, 250),
        BodyConfiguration = BodyConfiguration,
        CloseButtonConfiguration = CloseButtonConfiguration
    }

    return BasicConfiguration
end

vgui.Register("DTitleMenu", TitleMenu, "DFrame")