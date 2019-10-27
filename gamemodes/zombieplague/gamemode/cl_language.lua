Dictionary = {LanguageID = 1, Language = {}}


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
	if file.Exists("zombieplague/language.txt", "DATA") then
		LanguageID = (file.Read("zombieplague/language.txt", "DATA") or 1)
	end
end
net.Receive("SendPlayerLanguage", function()
	Dictionary:SetLanguageBook(net.ReadTable())
end)