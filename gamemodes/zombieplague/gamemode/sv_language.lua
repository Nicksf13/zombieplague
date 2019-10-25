Dictionary = {Languages = {}}

function Dictionary:SearchLanguages()
	local Files = file.Find("zombieplague/gamemode/languages/*.lua", "LUA")
	if Files then
		for k, File in pairs(Files) do
			include("zombieplague/gamemode/languages/" .. File)
		end
	end
end
function Dictionary:AddLanguage(Language)
	table.insert(Dictionary.Languages, Language)
end
function Dictionary:GetPhrase(PhraseID, ply)
	return Dictionary:GetServerSideLanguageBook(ply:GetLanguage())[PhraseID] or "{UNKNOWN}"
end
function Dictionary:GetLanguageBook(LanguageID)
	return Dictionary.Languages[LanguageID] or Dictionary.Languages[1]
end
function Dictionary:GetServerSideLanguageBook(LanguageID)
	return Dictionary:GetLanguageBook(LanguageID).Values.Server
end
function Dictionary:GetClientSideLanguageBook(LanguageID)
	if !Dictionary.Languages[LanguageID] then
		LanguageID = 1
	end
	return {ID = LanguageID, Value = Dictionary:GetLanguageBook(LanguageID).Values.Client}
end
function Dictionary:RegisterPhrase(LanguageAlias, PhraseID, Phrase, Client)
	local Language
	for k, Lang in pairs(self.Languages) do
		if Lang.ID == LanguageAlias then
			Language = Lang.Values
			break
		end
	end
	if Language then
		Language[(Client and "Client" or "Server")][PhraseID] = Phrase
	else
		print("Unknown language: '" .. LanguageAlias .. "'!")
	end
end
function Dictionary:GetLanguageIDs()
	local Languages = {}
	for k, v in pairs(Dictionary.Languages) do
		Languages[k] = v.ID
	end
	return Languages
end
function Dictionary:OpenLanguageMenu(ply)
	net.Start("OpenBackMenu")
		net.WriteString("SendLanguage")
		net.WriteTable(Dictionary:GetLanguageIDs())
	net.Send(ply)
end
Commands:AddCommand("zombies", "Open language menu.", function(ply, args)
	Dictionary:OpenLanguageMenu(ply)
end)
net.Receive("RequestLanguageMenu", function(len, ply)
	Dictionary:OpenLanguageMenu(ply)
end)
net.Receive("SendLanguage", function(len, ply)
	ply:SetLanguage(net.ReadInt(8))
end)
util.AddNetworkString("RequestLanguageMenu")
util.AddNetworkString("SendLanguage")