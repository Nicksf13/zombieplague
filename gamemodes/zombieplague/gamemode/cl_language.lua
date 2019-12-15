Dictionary = {LanguageID = "en-us", Language = {}}


function Dictionary:GetPhrase(PhraseID)
	return Dictionary:GetLanguageBook()[PhraseID] or "{UNKNOWN}"
end
function Dictionary:SetLanguageBook(LanguageID, Language, ShouldSave)
	if ShouldSave then
		if !file.Exists("zombieplague", "DATA") then
			file.CreateDir("zombieplague")
		end
		file.Write("zombieplague/language.txt", LanguageID)
	end
	
	Dictionary.Language = Language.Value
end
function Dictionary:GetLanguageBook()
	return Dictionary.Language or {}
end
function Dictionary:Start()
	if file.Exists("zombieplague/language.txt", "DATA") then
		Dictionary.LanguageID = (file.Read("zombieplague/language.txt", "DATA") or "en-us")
	end
end
net.Receive("SendPlayerLanguage", function()
	Dictionary:SetLanguageBook(net.ReadString(), net.ReadTable(), net.ReadBool())
end)