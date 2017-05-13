Dictionary = {Languages = {}}

function Dictionary:SearchLanguages()
	local Files = file.Find("zombieplague/gamemode/languages/*.lua", "LUA")
	if Files != nil then
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
	if Dictionary.Languages[LanguageID] == nil then
		LanguageID = 1
	end
	return {ID = LanguageID, Value = Dictionary:GetLanguageBook(LanguageID).Values.Client}
end
function Dictionary:GetLanguageIDs()
	local Languages = {}
	for k, v in pairs(Dictionary.Languages) do
		Languages[k] = v.ID
	end
	return Languages
end
function Dictionary:BroadcastColorMessage(PhraseID, Clr, Exclude)
	for k, ply in pairs(player.GetAll()) do
		if Exclude == nil || !table.HasValue(Exclude, ply) then
			SendColorMessage(ply, Dictionary:GetPhrase(PhraseID, ply), Clr)
		end
	end
end
function Dictionary:BroadcastPopupMessage(PhraseID, Exclude)
	for k, ply in pairs(player.GetAll()) do
		if Exclude == nil || !table.HasValue(Exclude, ply) then
			SendPopupMessage(ply, Dictionary:GetPhrase(PhraseID, ply))
		end
	end
end
function Dictionary:OpenLanguageMenu(ply)
	net.Start("OpenBackMenu")
		net.WriteString("SendLanguage")
		net.WriteTable(Dictionary:GetLanguageIDs())
	net.Send(ply)
end
hook.Add("PlayerSay", "ZPLanguages", function(ply, txt)
	if txt == "/languages" then
		Dictionary:OpenLanguageMenu(ply)
	end
end)
net.Receive("RequestLanguageMenu", function(len, ply)
	Dictionary:OpenLanguageMenu(ply)
end)
net.Receive("SendLanguage", function(len, ply)
	ply:SetLanguage(net.ReadInt(8))
end)
util.AddNetworkString("RequestLanguageMenu")
util.AddNetworkString("SendLanguage")