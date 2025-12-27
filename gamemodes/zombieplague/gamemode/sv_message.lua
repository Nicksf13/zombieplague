AddCSLuaFile("cl_message.lua")
local function WritePhrasePayload(PhraseID, Args)
	net.WriteString(PhraseID or "")
	net.WriteTable(Args or {})
end

function ZPPhraseArg(PhraseID)
	return {__phrase = PhraseID}
end

function BroadcastMessage(PhraseID, ...)
	for i, ply in ipairs(player.GetAll()) do
		SendColorMessage(ply, PhraseID, Color(255, 255, 255), ...)
	end
end
function BroadcastColorMessage(PhraseID, Clr, Exclude, ...)
	for i, ply in ipairs(player.GetAll()) do
		if !Exclude || !table.HasValue(Exclude, ply) then
			SendColorMessage(ply, PhraseID, Clr, ...)
		end
	end
end
function BroadcastSound(SoundPath, Exclude)
	for i, ply in ipairs(player.GetAll()) do
		if !Exclude || !table.HasValue(Exclude, ply) then
			SendSound(ply, SoundPath)
		end
	end
end
function BroadcastNotifyMessage(PhraseID, time, Clr, ...)
	for i, ply in ipairs(player.GetAll()) do
		SendNotifyMessage(ply, PhraseID, time, Clr, ...)
	end
end
function SendMessage(ply, PhraseID, ...)
	SendColorMessage(ply, PhraseID, Color(255, 255, 255), ...)
end
function SendColorMessage(ply, PhraseID, Clr, ...)
	net.Start("SendMessage")
		net.WriteColor(Clr)
		WritePhrasePayload(PhraseID, {...})
	net.Send(ply)
end
function SendConsoleMessage(ply, text)
	net.Start("SendConsoleMessage")
		net.WriteString(text)
	net.Send(ply)
end
function SendPopupMessage(ply, PhraseID, ...)
	net.Start("SendPopupMessage")
		WritePhrasePayload(PhraseID, {...})
	net.Send(ply)
end
function SendSound(ply, SoundPath)
	net.Start("SendSound")
		net.WriteString(SoundPath)
	net.Send(ply)
end
function SendNotifyMessage(ply, PhraseID, time, color, ...)
	net.Start("SendNotifyMessage")
		net.WriteInt(time or 5, 8)
		WritePhrasePayload(PhraseID, {...})
		net.WriteColor(color or Color(255, 255, 255))
	net.Send(ply)
end
util.AddNetworkString("SendMessage")
util.AddNetworkString("SendConsoleMessage")
util.AddNetworkString("SendPopupMessage")
util.AddNetworkString("SendSound")
util.AddNetworkString("SendNotifyMessage")