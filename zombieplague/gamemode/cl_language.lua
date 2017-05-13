Dictionary = {Language = {}}


function Dictionary:GetPhrase(PhraseID)
	return Dictionary:GetLanguageBook()[PhraseID] or "{UNKNOWN}"
end
function Dictionary:SetLanguageBook(Language)
	if !file.Exists("zombieplague", "DATA") then
		file.CreateDir("zombieplague")
	end
	file.Write("zombieplague/language.txt", Language.ID)
	
	Dictionary.Language = Language.Value
end
function Dictionary:GetLanguageBook()
	return Dictionary.Language or {}
end
function Dictionary:Start()
	local Language = 1
	if file.Exists("zombieplague/language.txt", "DATA") then
		Language = (file.Read("zombieplague/language.txt", "DATA") or 1)
	end
	net.Start("SendLanguage")
		net.WriteInt(tonumber(Language), 8)
	net.SendToServer()
end
net.Receive("SendPlayerLanguage", function()
	Dictionary:SetLanguageBook(net.ReadTable())
end)