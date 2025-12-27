local function ResolvePhraseArgs(Args)
	for i, Arg in ipairs(Args) do
		if istable(Arg) and Arg.__phrase then
			Args[i] = Dictionary:GetPhrase(Arg.__phrase)
		end
	end
	return Args
end

net.Receive("SendMessage", function()
	local MessageColor = net.ReadColor()
	local PhraseID = net.ReadString()
	local PhraseArgs = ResolvePhraseArgs(net.ReadTable())
	chat.AddText(MessageColor, "[ZP] ", Color(255, 255, 255), Dictionary:GetPhrase(PhraseID, unpack(PhraseArgs)))
end)
net.Receive("SendConsoleMessage", function()
	print(net.ReadString())
end)
net.Receive("SendPopupMessage", function()
	local PhraseID = net.ReadString()
	local PhraseArgs = ResolvePhraseArgs(net.ReadTable())
	notification.AddLegacy(Dictionary:GetPhrase(PhraseID, unpack(PhraseArgs)), NOTIFY_GENERIC, 5)
end)
net.Receive("SendSound", function()
	surface.PlaySound(net.ReadString())
end)
net.Receive("SendNotifyMessage", function()
	local ZPNotice = vgui.Create("DNotify")
	
	ZPNotice:SetLife(net.ReadInt(8))
	ZPNotice:SetSize(800, 40)
	ZPNotice:SetPos(ScrW() / 2 - 400, 30)
	
	local lbl = vgui.Create("DLabel", ZPNotice)
	lbl:Dock(FILL)
	lbl:SetFont("GModNotify")
	lbl:SetContentAlignment(5)
	local PhraseID = net.ReadString()
	local PhraseArgs = ResolvePhraseArgs(net.ReadTable())
	lbl:SetText(Dictionary:GetPhrase(PhraseID, unpack(PhraseArgs)))
	lbl:SetColor(net.ReadColor())
	
	ZPNotice:AddItem(lbl)
end)